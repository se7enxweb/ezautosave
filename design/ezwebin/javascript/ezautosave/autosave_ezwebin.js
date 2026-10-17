/**
 * Autosave of the edit form of the ezwebin design (content/edit/autosave.tpl of ezautosave) on Exponential UI
 * (exp::autosave). The template writes the settings, the server call and the texts as JSON
 * (<script type="application/json" id="ezautosave-settings">); this file, loaded with defer, starts the autosave, so
 * the edit page carries no inline script (Content Security Policy without 'unsafe-inline').
 */
(function ( window, document ) {
    'use strict';

    var element = document.getElementById( 'ezautosave-settings' ), conf;
    if ( !element || !window.Exp || !window.Exp.autosave || element.getAttribute( 'data-ezautosave-started' ) )
        return;
    element.setAttribute( 'data-ezautosave-started', '1' );
    try {
        conf = JSON.parse( element.textContent );
    } catch ( e ) {
        if ( window.console )
            window.console.error( 'ezautosave: #ezautosave-settings is not valid JSON', e );
        return;
    }

window.Exp.ready(function ($) {

    // a list in autosave.ini; json_encode writes an object when the INI keys are not 0, 1, 2 ...
    var ieList = conf.ieDisableWithPassword || [],
        ieDisableWithPassword = ( Array.isArray( ieList ) ? ieList : Object.keys( ieList ).map( function ( k ) { return ieList[k]; } ) ).map( Number ),
        as = new window.Exp.autosave.AutoSubmit({

            form: '#editform',
            action: conf.action,
            interval: conf.interval,
            trackUserInput: conf.trackUserInput,
            enabled: function () {

                if ( ieDisableWithPassword.indexOf( document.documentMode || 0 ) !== -1 ) {

                    return $(this.conf.form).find("input[type=password]").length == 0;
                }

                return true;
            }

        }),
        messages = conf.messages || {},
        timer = false, place,
        hideStoreButton = !!conf.hideStoreButton,
        hidePreviewLink = !!conf.hidePreviewLink;

    as.on('abort', function () {
        place.removeClass('as-saving as-error as-success').html('');
    });

    as.on('error', function (e) {
        if ( timer ) {
            window.clearInterval(timer);
        }
        place.removeClass('as-saving as-success').addClass('as-error')
             .html('<span>' + messages.error + '</span>');
        if ( e.json && e.json.error_text ) {
             place.attr('title', e.json.error_text);
        }
    });

    as.on('init', function () {
        var that = this;
        $('#ezwt').append('<div id="ez-as-place" class="as-init"></div>');
        place = $('#ez-as-place');
        place.css('top', (($('#ezwt')[0] || {}).offsetHeight - 1) + 'px');
        if ( hideStoreButton ) {
            $(this.conf.form).find('input[name=StoreButton]').hide();
        }
        if ( hidePreviewLink ) {
            $(this.conf.form).find('#preview-link').hide();
        }
        $(window).on('beforeunload', function () {
            setTimeout(function () {
                that.submit("StoreExitButton=1");
            }, 0);
        });
    });

    as.on('beforesave', function () {
        place.addClass('as-saving').removeClass('as-error as-success as-init')
             .html(messages.saving).attr('title', '');
    });

    as.on('success', function (e) {
        var counter = 0,
            msgAgo = e.json.content.message_ago,
            updateMsg = function () {
                var n = msgAgo.replace(counter, counter + 1);
                place.html(place.html().replace(msgAgo, n));
                msgAgo = n;
                counter++;
            };

        place.removeClass('as-error as-saving').addClass('as-success')
             .html(e.json.content.message_success + ' ' + msgAgo).attr('title', '');
        if ( timer ) {
            window.clearInterval(timer);
        }
        timer = window.setInterval(updateMsg, 60000);
    });

    as.start();

});
})( window, document );
