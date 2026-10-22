/**
 * Autosave and preview of the admin edit form (content/edit/autosave.tpl of ezautosave) on Exponential UI
 * (exp::autosave), in plain JavaScript: no jQuery needed. The template writes the settings, the server call and the
 * texts as JSON (<script type="application/json" id="ezautosave-settings">); this file, loaded with defer, starts the
 * autosave, so the edit page carries no inline script (Content Security Policy without 'unsafe-inline').
 */
(function ( window, document ) {
    'use strict';

    var element = document.getElementById( 'ezautosave-settings' ), conf;
    if ( !element || !window.Exp || !window.Exp.autosave )
        return;
    try {
        conf = JSON.parse( element.textContent );
    } catch ( e ) {
        if ( window.console )
            window.console.error( 'ezautosave: #ezautosave-settings is not valid JSON', e );
        return;
    }

    /** The elements of a selector (or the element given). */
    function all( target ) {
        if ( !target )
            return [];
        return typeof target === 'string' ? Array.prototype.slice.call( document.querySelectorAll( target ) ) : [target];
    }

    /** All elements below the ones of target that match selector. */
    function find( target, selector ) {
        return all( target ).reduce( function ( list, el ) { return list.concat( Array.prototype.slice.call( el.querySelectorAll( selector ) ) ); }, [] );
    }

    /** An element's height in px as jQuery's .css( 'height' ) reads it; undefined without the element. */
    function cssHeight( el ) {
        if ( !el )
            return undefined;
        var value = window.getComputedStyle( el ).height;
        if ( ( value === 'auto' || !parseFloat( value ) && window.getComputedStyle( el ).display === 'inline' ) && el.getClientRects().length )
            value = el.getBoundingClientRect().height;
        return ( parseFloat( value ) || 0 ) + 'px';
    }

window.Exp.ready(function () {

    // a list in autosave.ini; json_encode writes an object when the INI keys are not 0, 1, 2 ...
    var ieList = conf.ieDisableWithPassword || [],
        ieDisableWithPassword = ( Array.isArray( ieList ) ? ieList : Object.keys( ieList ).map( function ( k ) { return ieList[k]; } ) ).map( Number ),
        as = new window.Exp.autosave.AutoSubmit({

            form: '#editform',
            ignoreClass: 'no-autosave',
            action: conf.action,
            interval: conf.interval,
            trackUserInput: conf.trackUserInput,
            enabled: function () {

                if ( ieDisableWithPassword.indexOf( document.documentMode || 0 ) !== -1 ) {

                    return find( this.conf.form, "input[type=password]" ).length == 0;
                }

                return true;
            }

        }),
        messages = conf.messages,
        preview = new window.Exp.autosave.Preview({

            texts: conf.previewTexts,
            topPosition: cssHeight( document.querySelector( '#controlbar-top .box-bc' ) )
        }),
        timer = false, place = null,
        hideStoreButton = conf.hideStoreButton,
        hidePreviewLink = conf.hidePreviewLink;

    // the status place's classes and HTML; undefined HTML changes nothing (as jQuery's .html( undefined ))
    function setPlace( remove, add, html ) {
        if ( !place )
            return;
        remove.forEach( function ( c ) { place.classList.remove( c ); } );
        add.forEach( function ( c ) { place.classList.add( c ); } );
        if ( html !== undefined )
            place.innerHTML = html;
    }
    function setTitle( title ) {
        if ( place && title !== undefined )
            place.setAttribute( 'title', title );
    }

    as.on('abort', function () {
        setPlace( ['as-saving', 'as-error', 'as-success'], [], '' );
    });

    as.on('error', function (e) {
        if ( timer ) {
            window.clearInterval(timer);
        }
        setPlace( ['as-saving', 'as-success'], ['as-error'], '<span>' + messages.error + '</span>' );
        if ( e.json && e.json.error_text ) {
            setTitle( e.json.error_text );
            preview.error(e.json.error_text);
        } else {
            preview.error();
        }
    });

    as.on('init', function () {
        var that = this;
        all( '#controlbar-top .button-right' ).forEach( function ( right ) {
            right.insertAdjacentHTML( 'afterbegin', '<em id="ez-as-place"></em>' );
        });
        place = document.getElementById( 'ez-as-place' );
        preview.init();
        if ( hideStoreButton ) {
            find( this.conf.form, 'input[name=StoreButton]' ).forEach( function ( button ) { button.style.display = 'none'; } );
        }
        if ( hidePreviewLink ) {
            find( this.conf.form, '#preview-link' ).forEach( function ( link ) { link.style.display = 'none'; } );
        }
        window.addEventListener('beforeunload', function () {
            setTimeout(function () {
                that.submit("StoreExitButton=1");
            }, 0);
        });
    });

    as.on('beforesave', function () {
        setPlace( [], ['as-saving'] );
        setPlace( ['as-error', 'as-success'], [], messages.saving );
        setTitle( '' );
        preview.loading();
    });

    as.on('success', function (e) {
        var counter = 0,
            msgAgo = e.json.content.message_ago,
            updateMsg = function () {
                var n = msgAgo.replace(counter, counter + 1);
                if ( place ) {
                    place.innerHTML = place.innerHTML.replace(msgAgo, n);
                }
                msgAgo = n;
                counter++;
            };

        setPlace( ['as-error', 'as-saving'], ['as-success'], e.json.content.message_success + ' ' + msgAgo );
        setTitle( '' );
        if ( !preview.collapsible.conf.collapsed ) {
            preview.setContent(e.json.content.preview);
        }
        if ( timer ) {
            window.clearInterval(timer);
        }
        timer = window.setInterval(updateMsg, 60000);
    });

    as.start();

});
})( window, document );
