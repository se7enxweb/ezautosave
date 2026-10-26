<?php

use PHPUnit\Framework\TestCase;

/**
 * The admin edit form's autosave (design/admin/templates/content/edit/autosave.tpl) carries no inline script: its
 * settings are a JSON block with < and > escaped, and javascript/ezautosave/autosave_admin.js starts it, so the page
 * runs under a Content Security Policy without 'unsafe-inline'.
 */
class AdminAutosaveScriptTest extends TestCase
{
    private static function read( string $path ): string
    {
        return (string)file_get_contents( dirname( __DIR__, 2 ) . '/' . $path );
    }

    public function testTemplateHasOnlyTheJsonBlockAndTheFile(): void
    {
        $tpl = preg_replace( '/\{\*.*?\*\}/s', '', self::read( 'design/admin/templates/content/edit/autosave.tpl' ) );
        preg_match_all( '/<script\b[^>]*>/i', $tpl, $m );
        $this->assertCount( 2, $m[0] );
        $this->assertStringContainsString( 'type="application/json" id="ezautosave-settings"', $m[0][0] );
        $this->assertStringContainsString( 'autosave_admin.js', $m[0][1] );
        $this->assertStringContainsString( ' defer', $m[0][1] );
        $this->assertDoesNotMatchRegularExpression( '/\son[a-z]+\s*=|<style\b|style="/i', $tpl );
        // a text can not end the block early
        $this->assertStringContainsString( "|explode( '<' )|implode( '\\u003c' )", $tpl );
        $this->assertStringContainsString( "|explode( '>' )|implode( '\\u003e' )", $tpl );
        // admin4 loads no exp:: module on every page: the template requests the autosave (and the collapse of its
        // preview) itself, before the deferred file that starts it
        $this->assertStringContainsString( "{ezscript_require( array( 'exp::core::shared', 'exp::collapse', 'exp::autosave' ) )}", $tpl );
        $this->assertLessThan( strpos( $tpl, 'autosave_admin.js' ), strpos( $tpl, "'exp::autosave'" ) );
    }

    public function testScriptReadsEverySettingTheTemplateWrites(): void
    {
        $tpl = self::read( 'design/admin/templates/content/edit/autosave.tpl' );
        $js = self::read( 'design/admin/javascript/ezautosave/autosave_admin.js' );
        foreach ( array( 'action', 'interval', 'trackUserInput', 'ieDisableWithPassword', 'messages', 'previewTexts',
                         'hideStoreButton', 'hidePreviewLink' ) as $key )
        {
            $this->assertStringContainsString( '"' . $key . '":', $tpl, $key );
            $this->assertStringContainsString( 'conf.' . $key, $js, $key );
        }
        $this->assertStringContainsString( "getElementById( 'ezautosave-settings' )", $js );
        $this->assertStringContainsString( 'JSON.parse', $js );
    }
}
