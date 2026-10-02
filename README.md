About eZ Autosave
=================

Project page: http://projects.ez.no/ezautosave
Roadmap feature request:
http://share.ez.no/feature-requests/auto-store-draft-feature

eZ Autosave enables the automatic and transparent saving of the draft
while editing a content in eZ Publish. Based on this, it also provides
an "inline" preview from the content edit in the administration
interface.

This extension is based on QH Autosave by Quoc-Huy NGUYEN DINH


Features
========

- Regularly save the draft (interval defined in
  `autosave.ini/[AutosaveSettings]/Interval`)
- Save the draft when the user leaves a form field (enable/disable
  through `autosave.ini/[AutosaveSettings]/TrackUserInput`)
- Hide the "Store draft" button (enable/disable through
  `autosave.ini/[AutosaveSettings]/HideStoreDraftButton`)
- Try to save the draft if the editor unexpectedly quits the content
  edit page (back button, close browser, ...)

Requirements
============

- eZ Publish 2012.01 or 4.7 or newer

TODO / Known issues
===================

- When timeout is implemented, add a Retry button in case of timeout
- Use the output of the ezjscore action to update the content edit form:
  for instance, after uploading an image, the preview could be updated
  or the unvalidated field could be hightlighted.
- Let the editor disable/enable the autosave process
- Let the editor choose the interval between two autosave attempts


Technical notes
===============

The autosave runs on Exponential UI's `Exp.autosave.AutoSubmit` (exp::autosave,
extension expui). It submits a form at a fixed interval, or when the user has
changed something, to an ezjscore call, and triggers these events:

- init
- beforesave
- success
- error
- abort

The admin's preview pane is `Exp.autosave.Preview`. The edit templates of this
extension (design/admin and design/ezwebin, content/edit/autosave.tpl) show
both in use. A minimal example:

    {exp_config()}
    {ezscript_require( array( 'ezjsc::jquery', 'exp::core::shared', 'exp::io', 'exp::autosave' ) )}
    <script type="text/javascript">
    Exp.ready(function ($) {
        var as = new Exp.autosave.AutoSubmit({
            form: '#editform',
            action: '/ezjscore/call/ezautosave::savedraft::42::3::eng-GB?ContentType=javascript',
            interval: 60,
            trackUserInput: true
        });
        as.on('success', function (e) { console.log(e.json.content.message_success); });
        as.start();
    });
    </script>
