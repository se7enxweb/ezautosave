/**
 * Autosave and preview of the admin edit form (content/edit/autosave.tpl of ezautosave) on Exponential UI
 * (exp::autosave). The template writes the settings, the server call and the texts as JSON
 * (<script type="application/json" id="ezautosave-settings">); this file, loaded with defer, starts the autosave, so
 * the edit page carries no inline script (Content Security Policy without 'unsafe-inline').
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

window.Exp.ready(function ($) {

    var ieDisableWithPassword = ( conf.ieDisableWithPassword || [] ).map( Number ),
        as = new window.Exp.autosave.AutoSubmit({

            form: '#editform',
            ignoreClass: 'no-autosave',
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
        messages = conf.messages,
        preview = new window.Exp.autosave.Preview({

            texts: conf.previewTexts,
            topPosition: $('#controlbar-top .box-bc').css('height')
        }),
        timer = false, place,
        hideStoreButton = conf.hideStoreButton,
        hidePreviewLink = conf.hidePreviewLink;

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
            preview.error(e.json.error_text);
        } else {
            preview.error();
        }
    });

    as.on('init', function () {
        var that = this;
        $('#controlbar-top .button-right').prepend('<em id="ez-as-place"></em>');
        place = $('#ez-as-place');
        preview.init();
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
        place.addClass('as-saving').removeClass('as-error as-success')
             .html(messages.saving).attr('title', '');
        preview.loading();
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
