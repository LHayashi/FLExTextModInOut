<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">
    
    <!-- Identity transform to copy all other content -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Match rt elements that are Segments -->
    <xsl:template match="rt[@class='Segment']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            
            <!-- Add the <Custom name="InOut"> element -->
            <Custom name="InOut">
                <AStr ws="en">
                    <Run ws="en">
                        <xsl:text>\in </xsl:text>
                        <xsl:value-of select="BeginTimeOffset/Uni"/>
                        <xsl:text> \out </xsl:text>
                        <xsl:value-of select="EndTimeOffset/Uni"/>
                        <xsl:text> \sf </xsl:text>
                        
                        <!-- Lookup MediaURI filename -->
                        <xsl:variable name="mediaGuid" select="MediaURI/objsur/@guid"/>
                        <xsl:variable name="mediaPath" select="/*/rt[@class='CmMediaURI' and @guid=$mediaGuid]/MediaURI/Uni"/>
                        <xsl:value-of select="tokenize($mediaPath, '/')[last()]"/>
                    </Run>
                </AStr>
            </Custom>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
