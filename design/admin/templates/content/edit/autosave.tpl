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
{if ezini( 'AutosaveSettings', 'HidePreviewLink', 'autosave.ini' )|eq( 'enabled' ) }
{def $as_ajax_request = 'ezjscore/call/ezautosave::savedraft' }
{else}
{def $as_ajax_request = 'ezjscore/call/ezautosave::savedraftpreview' }
{/if}
<script type="text/javascript">

// The draft is saved and previewed on Exponential UI (exp::autosave): these settings, server calls, messages and
// markup
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
{rdelim}
</script>
