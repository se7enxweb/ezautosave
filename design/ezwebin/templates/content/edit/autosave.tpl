{ezcss_require( 'autosave.css' )}
{* The draft is saved on Exponential UI (exp::autosave), with the page configuration it reads (front-end designs do not
   load the admin's script list) *}
{exp_config()}
{ezscript_require( array( 'ezjsc::jquery', 'exp::core::shared', 'exp::io', 'exp::collapse', 'exp::autosave' ) )}
<script type="text/javascript">

if ( window.Exp && window.Exp.autosave ) {ldelim}
Exp.ready(function ($) {ldelim}

    var as = new Exp.autosave.AutoSubmit({ldelim}

            form: '#editform',
            action: {concat( 'ezjscore/call/ezautosave::savedraft::', $object.id, '::', $edit_version, '::', $edit_language, '?ContentType=javascript' )|ezurl},
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

            error: "{'An error occurred while autosaving the draft'|i18n( 'design/ezwebin/autosave' )|wash( 'javascript' )}",
            saving: "{'The draft is being saved'|i18n( 'design/ezwebin/autosave' )|wash( 'javascript' )}"
        {rdelim},
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
    {/literal}

{rdelim});
{rdelim}
</script>
