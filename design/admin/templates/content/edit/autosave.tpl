{literal}
<!--[if IE 6]>
<style>
.controlbar-fixed #preview-link, .controlbar-fixed #preview-spacer
{
display:none;
}
</style>
<![endif]-->
{/literal}
{ezscript_require( array( 'ezjsc::yui3', 'ezautosubmit.js' ) )}
{if ezini( 'AutosaveSettings', 'HidePreviewLink', 'autosave.ini' )|eq( 'enabled' ) }
{def $as_ajax_request = 'ezjscore/call/ezautosave::savedraft' }
{else}
{def $as_ajax_request = 'ezjscore/call/ezautosave::savedraftpreview' }
{/if}
<script type="text/javascript">

// With Exponential UI (exp::autosave) the draft is saved and previewed on it, without YUI; the same settings, server
// calls, messages and markup as the YUI version below
if ( window.Exp && window.Exp.autosave ) {ldelim}
Exp.ready(function ($) {ldelim}

    var as = new Exp.autosave.AutoSubmit({ldelim}

            form: '#editform',
            ignoreClass: 'no-autosave',
            action: {concat( $as_ajax_request, '::', $object.id, '::', $edit_version, '::', $edit_language, '?ContentType=javascript' )|ezurl},
            interval: {ezini( 'AutosaveSettings', 'Interval', 'autosave.ini' )|int()},
            trackUserInput: {cond( ezini( 'AutosaveSettings', 'TrackUserInput', 'autosave.ini')|eq( 'enabled' ), "true", "false" )},
            enabled: function () {ldelim}

                var ieDisableWithPassword = [{ezini( 'BrowserWorkarounds', 'IEDisableWithPassword', 'autosave.ini' )|implode( ', ')}];

                if ( ieDisableWithPassword.indexOf( document.documentMode || 0 ) !== -1 ) {ldelim}

                    return $(this.conf.form).find("input[type=password]").length == 0;
                {rdelim}

                return true;
            {rdelim}

        {rdelim}),
        messages = {ldelim}

            error: "{'An error occurred while autosaving the draft'|i18n( 'design/admin2/autosave' )|wash( 'javascript' )}",
            saving: "{'The draft is being saved'|i18n( 'design/admin2/autosave' )|wash( 'javascript' )}"
        {rdelim},
        preview = new Exp.autosave.Preview({ldelim}

            texts: {ldelim}

                loading: "{'Loading...'|i18n( 'design/admin2/preview' )|wash( 'javascript' )}",
                error: "{'An error occurred.'|i18n( 'design/admin2/preview' )|wash( 'javascript' )}",
                preview: "{'Preview'|i18n( 'design/admin2/preview' )|wash( 'javascript' )}"
            {rdelim},
            topPosition: $('#controlbar-top .box-bc').css('height')
        {rdelim}),
        timer = false, place,
        hideStoreButton = {cond( ezini( 'AutosaveSettings', 'HideStoreDraftButton', 'autosave.ini' )|eq( 'enabled' ), "true", "false" )},
        hidePreviewLink = {cond( ezini( 'AutosaveSettings', 'HidePreviewLink', 'autosave.ini' )|eq( 'enabled' ), "true", "false" )};

    {literal}

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
    {/literal}

{rdelim});
{rdelim} else
YUI(YUI3_config).use('ezautosubmit', 'ezcontentpreview', 'node-base', 'node-style', function (Y) {ldelim}

    var as = new Y.eZ.AutoSubmit({ldelim}

            form: '#editform',
            ignoreClass: 'no-autosave',
            action: {concat( $as_ajax_request, '::', $object.id, '::', $edit_version, '::', $edit_language, '?ContentType=javascript' )|ezurl},
            interval: {ezini( 'AutosaveSettings', 'Interval', 'autosave.ini' )|int()},
            trackUserInput: {cond( ezini( 'AutosaveSettings', 'TrackUserInput', 'autosave.ini')|eq( 'enabled' ), "true", "false" )},
            enabled: function () {ldelim}

                var ieDisableWithPassword = [{ezini( 'BrowserWorkarounds', 'IEDisableWithPassword', 'autosave.ini' )|implode( ', ')}];

                if ( ieDisableWithPassword.indexOf(Y.UA.ie) !== -1 ) {ldelim}

                    return (Y.one(this.conf.form).all("input[type=password]").size() == 0);
                {rdelim}

                return true;
            {rdelim}

        {rdelim}),
        messages = {ldelim}

            error: "{'An error occurred while autosaving the draft'|i18n( 'design/admin2/autosave' )|wash( 'javascript' )}",
            saving: "{'The draft is being saved'|i18n( 'design/admin2/autosave' )|wash( 'javascript' )}"
        {rdelim},
        preview = new Y.eZ.ContentPreview({ldelim}

            texts: {ldelim}

                loading: "{'Loading...'|i18n( 'design/admin2/preview' )|wash( 'javascript' )}",
                error: "{'An error occurred.'|i18n( 'design/admin2/preview' )|wash( 'javascript' )}",
                preview: "{'Preview'|i18n( 'design/admin2/preview' )|wash( 'javascript' )}"
            {rdelim},
            topPosition: Y.one('#controlbar-top .box-bc').getStyle('height')
        {rdelim}),
        timer = false, place;

    {literal}

    as.on('abort', function() {
        place.removeClass('as-saving')
             .removeClass('as-error')
             .removeClass('as-success')
             .setContent('');
    });

    as.on('error', function (e) {
        if ( timer ) {
            timer.cancel();
        }
        place.removeClass('as-saving')
             .removeClass('as-success')
             .addClass('as-error')
             .setContent('<span>' + messages.error + '</span>');
        if ( e.json && e.json.error_text ) {
            place.setAttribute('title', e.json.error_text);
            preview.error(e.json.error_text);
        } else {
            preview.error();
        }
    });

    as.on('init', function () {
        var that = this;
        Y.one('#controlbar-top .button-right').prepend(
            '<em id="ez-as-place"></em>'
        );
        place = Y.one('#ez-as-place');
        preview.init();
{/literal}
        {if ezini( 'AutosaveSettings', 'HideStoreDraftButton', 'autosave.ini' )|eq( 'enabled' )}Y.all(this.conf.form + ' input[name=StoreButton]').each(function () {ldelim} this.hide() {rdelim});{/if}
        {if ezini( 'AutosaveSettings', 'HidePreviewLink', 'autosave.ini' )|eq( 'enabled' )}Y.all(this.conf.form + ' #preview-link').each(function () {ldelim} this.hide() {rdelim});{/if}
{literal}
        Y.on('beforeunload', function (e) {
            setTimeout(function () {
                that.submit("StoreExitButton=1");
            }, 0);
        });
    });

    as.on('beforesave', function () {
        place.addClass('as-saving')
             .removeClass('as-error')
             .removeClass('as-success')
             .setContent(messages.saving)
             .setAttribute('title', '');
        preview.loading();
    });

    as.on('success', function (e) {
        var counter = 0,
            msgAgo = e.json.content.message_ago,
            updateMsg = function () {
                var n = msgAgo.replace(counter, counter + 1);
                place.setContent(place.getContent().replace(msgAgo, n));
                msgAgo = n;
                counter++;
            };

        place.removeClass('as-error')
             .removeClass('as-saving')
             .addClass('as-success')
             .setContent(e.json.content.message_success + ' ' + msgAgo)
             .setAttribute('title', '');
        if ( !preview.collapsible.conf.collapsed ) {
            preview.setContent(e.json.content.preview);
        }
        if ( timer ) {
            timer.cancel();
        }
        timer = Y.later(60000, this, updateMsg, [], true);
    });

    as.start();
    {/literal}

{rdelim});

</script>
