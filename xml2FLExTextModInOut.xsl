<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<!-- Larry Hayashi November 13 2023 -->

	<xsl:template match="phrase">
		<xsl:variable name="vPOS">
			<xsl:number count="phrase" level="any" format="1"/>
		</xsl:variable>
		<xsl:variable name="vMediaFileGUID" select="@media-file"/>
		<xsl:copy>
			<!--The goal of this transform is to have reconciled user-edited offsets (captured in Notes on text segments
				with the attributes on phrase xml in FLExText.-->
			<!-- If there are Notes in with the segment that start with \in then
				copy the value of the \in to begin-time-offset
				copy the value of the \out to end-time-offset
				and if there is \sf then copy to media-file attribute-->
			<!-- The user can modify the Notes if needed
				so this transform copies the Notes over any existing data in these offsets.-->
			<!--If for some reason there are no Notes that begin with \in but there are @begin-time-offset and end-time-offset
				then create a Note with those offsets stored as \in, \out and \sf.-->

			<xsl:if test="starts-with(item[@type = 'note'], '\in ')">
				<xsl:attribute name="begin-time-offset">
					<xsl:value-of
						select="number(normalize-space(substring-before(substring-after(item[@type = 'note'], '\in '), '\out')))*1000"
					/>
				</xsl:attribute>
				<xsl:attribute name="end-time-offset">
					<xsl:value-of
						select="number(normalize-space(substring-before(substring-after(concat(item[@type = 'note'], '\'), '\out '), '\')))*1000"
					/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="contains(item[@type = 'note'], '\sf ')">
				<xsl:attribute name="media-file">
					<xsl:value-of
						select="normalize-space(substring-before(substring-after(concat(item[@type = 'note'], '\'), '\sf '), '\'))"
					/>
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="starts-with(item[@type = 'note'], '\in ')">
					<xsl:copy-of
						select="@*[not(name() = 'begin-time-offset' or name() = 'end-time-offset' or name() = 'media-file')]"
					/>
				</xsl:when>
				<!-- If there is no Note field starting with \in, then use the values already present in attributes on the segments.
					i.e. There is NO USER override whatsoever. This will only occur with FLExText files that did NOT
					have Notes added (by this XSLT) before IMPORT into FieldWorks. There is no manual addition of Note \in and there
					is no prior automated addition of Note \in either. -->
				<xsl:otherwise>
					<xsl:copy-of select="@*"/>
				</xsl:otherwise>
			</xsl:choose>
			<!--<xsl:if test="starts-with(item[@type = 'note'], '\in ')">
				<xsl:copy-of
					select="@*[not(name() = 'begin-time-offset' or name() = 'end-time-offset' or name() = 'media-file')]"
				/>	
			</xsl:if>-->
			<!--<xsl:copy-of select="@*"/>-->
			<xsl:apply-templates/>
			<xsl:if test="not(starts-with(item[@type = 'note'], '\in '))">
				<item type="note" lang="en">
					<xsl:text>\in </xsl:text>
					<xsl:value-of select="@begin-time-offset"/>
					<xsl:text> \out </xsl:text>
					<xsl:value-of select="@end-time-offset"/>
					<xsl:if test="$vPOS = 1">
						<xsl:text> \sf </xsl:text>
						<xsl:value-of select="//media[@guid = $vMediaFileGUID]/@location"/>
					</xsl:if>
				</item>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!--<xsl:template match="item[@type='note'][starts-with(., '\in')]"/>-->

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
