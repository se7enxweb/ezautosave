{ezcss_require( 'autosave.css' )}
{* The draft is saved on Exponential UI (exp::autosave), with the page configuration it reads (front-end designs do not
   load the admin's script list) *}
{exp_config()}
{ezscript_require( array( 'ezjsc::jquery', 'exp::core::shared', 'exp::io', 'exp::collapse', 'exp::autosave' ) )}
{* The settings of the autosave as data; javascript/ezautosave/autosave_ezwebin.js reads them and starts it, so the
   edit page carries no inline script. Printed with < and > as < and >: json_encode leaves "<!--" as it is,
   and "<!--<script>" in a text would make the browser skip the scripts after the block. *}
{set-block variable=$as_settings_json}
{ldelim}
    "action": {json_encode( concat( 'ezjscore/call/ezautosave::savedraft::', $object.id, '::', $edit_version, '::', $edit_language, '?ContentType=javascript' )|ezurl( 'no' ) )},
    "interval": {ezini( 'AutosaveSettings', 'Interval', 'autosave.ini' )|int()},
    "trackUserInput": {cond( ezini( 'AutosaveSettings', 'TrackUserInput', 'autosave.ini')|eq( 'enabled' ), "true", "false" )},
    "ieDisableWithPassword": {json_encode( ezini( 'BrowserWorkarounds', 'IEDisableWithPassword', 'autosave.ini' ) )},
    "messages": {ldelim}
        "error": {json_encode( 'An error occurred while autosaving the draft'|i18n( 'design/ezwebin/autosave' ) )},
        "saving": {json_encode( 'The draft is being saved'|i18n( 'design/ezwebin/autosave' ) )}
    {rdelim},
    "hideStoreButton": {cond( ezini( 'AutosaveSettings', 'HideStoreDraftButton', 'autosave.ini' )|eq( 'enabled' ), "true", "false" )},
    "hidePreviewLink": {cond( ezini( 'AutosaveSettings', 'HidePreviewLink', 'autosave.ini' )|eq( 'enabled' ), "true", "false" )}
{rdelim}
{/set-block}
<script type="application/json" id="ezautosave-settings">{$as_settings_json|explode( '<' )|implode( '<' )|explode( '>' )|implode( '>' )}</script>
{undef $as_settings_json}
<script src="{'javascript/ezautosave/autosave_ezwebin.js'|ezdesign( 'no' )}" defer></script>
