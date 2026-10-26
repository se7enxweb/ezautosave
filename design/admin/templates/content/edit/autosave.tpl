{if ezini( 'AutosaveSettings', 'HidePreviewLink', 'autosave.ini' )|eq( 'enabled' ) }
{def $as_ajax_request = 'ezjscore/call/ezautosave::savedraft' }
{else}
{def $as_ajax_request = 'ezjscore/call/ezautosave::savedraftpreview' }
{/if}
{* The settings of the autosave as data; javascript/ezautosave/autosave_admin.js reads them and starts it on
   Exponential UI (exp::autosave), so the edit page carries no inline script. Printed with < and > as \u003c and
   \u003e: json_encode leaves "<!--" as it is, and "<!--<script>" in a text would make the browser skip the scripts
   after the block. *}
{set-block variable=$as_settings_json}
{ldelim}
    "action": {json_encode( concat( $as_ajax_request, '::', $object.id, '::', $edit_version, '::', $edit_language, '?ContentType=javascript' )|ezurl( 'no' ) )},
    "interval": {ezini( 'AutosaveSettings', 'Interval', 'autosave.ini' )|int()},
    "trackUserInput": {cond( ezini( 'AutosaveSettings', 'TrackUserInput', 'autosave.ini')|eq( 'enabled' ), "true", "false" )},
    "ieDisableWithPassword": {json_encode( ezini( 'BrowserWorkarounds', 'IEDisableWithPassword', 'autosave.ini' ) )},
    "messages": {ldelim}
        "error": {json_encode( 'An error occurred while autosaving the draft'|i18n( 'design/admin2/autosave' ) )},
        "saving": {json_encode( 'The draft is being saved'|i18n( 'design/admin2/autosave' ) )}
    {rdelim},
    "previewTexts": {ldelim}
        "loading": {json_encode( 'Loading...'|i18n( 'design/admin2/preview' ) )},
        "error": {json_encode( 'An error occurred.'|i18n( 'design/admin2/preview' ) )},
        "preview": {json_encode( 'Preview'|i18n( 'design/admin2/preview' ) )}
    {rdelim},
    "hideStoreButton": {cond( ezini( 'AutosaveSettings', 'HideStoreDraftButton', 'autosave.ini' )|eq( 'enabled' ), "true", "false" )},
    "hidePreviewLink": {cond( ezini( 'AutosaveSettings', 'HidePreviewLink', 'autosave.ini' )|eq( 'enabled' ), "true", "false" )}
{rdelim}
{/set-block}
<script type="application/json" id="ezautosave-settings">{$as_settings_json|explode( '<' )|implode( '\u003c' )|explode( '>' )|implode( '\u003e' )}</script>
{undef $as_settings_json}
{* Exponential UI's autosave (with exp::collapse for its preview): the older admin designs load every exp:: module on
   every page (design.ini ClassicBackendJavaScriptList), admin4 only what a template requests; the head prints the
   request before this deferred file runs. Without jQuery. Without the expui extension there is no autosave. *}
{if ezini( 'ExtensionSettings', 'ActiveExtensions' )|contains( 'expui' )}
{ezscript_require( array( 'exp::core::shared', 'exp::collapse', 'exp::autosave' ) )}
{/if}
<script src="{'javascript/ezautosave/autosave_admin.js'|ezdesign( 'no' )}" defer></script>
