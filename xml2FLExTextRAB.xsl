<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	exclude-result-prefixes="xs" version="3.0">
	<xsl:output method="text" encoding="UTF-8" indent="yes"/>
	<!-- Larry Hayashi March 21 2024 -->
	<!-- This generates a number of products for Reading App Builder including:
		USFM coded text with each story being a different chapter
		Phrase timing files in CSV
		-->	

	<xsl:template match="document">
		<xsl:variable name="vRandom-seed" select="random-number-generator()"/>
		<xsl:variable name="vRandom-number"
			select="format-number(($vRandom-seed('permute')((current-dateTime() - xs:dateTime('1970-01-01T00:00:00Z')) div xs:dayTimeDuration('PT1S')) mod 10000000), '0000000')"/>
		<xsl:variable name="vMediaFileGUID" select="$vRandom-number"/>
		<!-- Sometimes a flextext file will contain multiple flextexts from different texts inside the project.
			Each one might have its own associated sound or video file.
			So here, we crawl through the entire flextext <document>
			looking for each <interlinear-text>.
			We get the sound file listed, usually in the 1st segment of the text in the InOut field with a \sf.-->
		<xsl:text>\id </xsl:text><!--<xsl:value-of select="$vTitleAbbreviation"/>-->Haisla Nuyem<xsl:text>&#xD;&#xA;</xsl:text> <!-- CR followed by LF -->	
		<xsl:for-each select="interlinear-text">
				<xsl:variable name="vInterlinearText">
					<xsl:number count="interlinear-text" level="any" format="1"/>
				</xsl:variable>
				<xsl:variable name="vTitleAbbreviation">
					<xsl:choose>
						<xsl:when test="item[@type='title-abbreviation'][@lang='en']">
							<xsl:value-of select="item[@type='title-abbreviation'][@lang='en']/text()"/>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="item[@type='title'][@lang='en']/text()"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!--<xsl:result-document method="text" href="{$vTitleAbbreviation}.txt" indent="no">-->
					
					<xsl:text>\c </xsl:text><xsl:value-of select="$vInterlinearText"/><xsl:text>&#xD;&#xA;</xsl:text> <!-- CR followed by LF -->
					<xsl:text>\toc2 </xsl:text><xsl:value-of select="item[@type='title'][@lang='has']"/><xsl:text>&#xD;&#xA;</xsl:text> <!-- CR followed by LF -->
				<xsl:text>\s1 </xsl:text><xsl:value-of select="item[@type='title'][@lang='has']"/><xsl:text>&#xD;&#xA;</xsl:text> <!-- CR followed by LF -->
			<xsl:text>\pc </xsl:text><xsl:value-of select="item[@type='title'][@lang='en']"/><xsl:text>&#xD;&#xA;</xsl:text> <!-- CR followed by LF -->
			<xsl:text>\pc </xsl:text><xsl:value-of select="item[@type='source'][@lang='en']"/><xsl:text>&#xD;&#xA;</xsl:text> <!-- CR followed by LF -->
					<!--<interlinear-text>-->
					<!--<xsl:variable name="vMediaFileName" select="paragraphs/paragraph/phrases/phrase/item[@type='InOut'][contains(text(),'\sf ')]/substring-after(text(), 'sf ')"/>-->
					<xsl:variable name="vMediaFileName" select=".//item[@type='InOut'][contains(.,'\sf ')]/substring-after(., 'sf ')"/>
					
					<!--<xsl:copy-of select="@*"/>-->
					<!--<xsl:apply-templates select=""><xsl:with-param name="pMediaFileGUID" select="$vMediaFileGUID"></xsl:with-param></xsl:apply-templates>-->
					<xsl:apply-templates select="paragraphs/paragraph"/>
					<xsl:call-template name="media-files">
						<xsl:with-param name="pMediaFileName" select="$vMediaFileName"></xsl:with-param>
					</xsl:call-template>
				<!--</interlinear-text>-->
				<!--</xsl:result-document>-->
			</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="paragraphs/paragraph">
		<!--<xsl:text>\p </xsl:text><xsl:text>&#xD;&#xA;</xsl:text> <!-\- CR followed by LF -\->-->
		<xsl:apply-templates select="phrases/phrase/item[@type='txt'][@lang='has']"></xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="phrases/phrase/item[@type='txt'][@lang='has']">
		<xsl:text>\m </xsl:text><xsl:value-of select="text()"/><xsl:text>&#xD;&#xA;</xsl:text> <!-- CR followed by LF -->
	</xsl:template>

	<!--<xsl:template name="oldphraseThatMatchedPhrase">
		<xsl:param name="pMediaFileGUID"/>
		<!-\- vPOS stores the position of the current phrase among phrases-\->
		<xsl:variable name="vPOS">
			<xsl:number count="phrase" level="any" format="1"/>
		</xsl:variable>
		<!-\-<xsl:variable name="vMediaFileName" select="normalize-space(substring-before(substring-after(concat(item[@type = 'note'], '\'), '\sf '), '\'))"/>-\->
		<xsl:copy>
			<!-\-The goal of this transform is to have reconciled user-edited offsets (captured in Notes on text segments
				with the attributes on phrase xml in FLExText.-\->
			<!-\- If there is a custom field InOut with the segment then
				copy the value of the \in to begin-time-offset
				copy the value of the \out to end-time-offset
				and if there is \sf then copy to media-file attribute-\->
			<!-\- The user can modify the InOut data if needed
				so this transform copies the InOut data over any existing data in these begin-time-offset and end-time-offset.-\->
			<!-\-If for some reason there is no InOut custom field but there are @begin-time-offset and end-time-offset
				then create an InOut custom field with those offsets stored as \in, \out and \sf.-\->
			<!-\- Floor() rounds down to nearest integer.-\->


			<!-\- Export / Copy InOut custom field data to begin-time-offset and end-time-offset -\->
			<xsl:if test="item[@type = 'InOut']">
				<xsl:attribute name="begin-time-offset">
					<xsl:value-of
						select="floor(number(normalize-space(substring-before(substring-after(item[@type = 'InOut'], '\in '), '\out'))) * 1000)"
					/>
				</xsl:attribute>
				<xsl:attribute name="end-time-offset">
					<xsl:value-of
						select="floor(number(normalize-space(substring-before(substring-after(concat(item[@type = 'InOut'], '\'), '\out '), '\'))) * 1000)"
					/>
				</xsl:attribute>
				<xsl:attribute name="media-file" select="$pMediaFileGUID"/>
			</xsl:if>
			<!-\-<xsl:if test="contains(item[@type = 'InOut'], '\sf ')">
				<!-\\-<xsl:variable name="vMediaFileName" select="normalize-space(substring-before(substring-after(concat(item[@type = 'InOut'], '\'), '\sf '), '\'))"/>-\\->
				<xsl:attribute name="media-file" select="$pMediaFileGUID"/>-\->
			<!-\-</xsl:if>-\->
			<!-\-<xsl:choose>
				<xsl:when test="starts-with(item[@type = 'note'], '\in ')">
					<xsl:copy-of
						select="@*[not(name() = 'begin-time-offset' or name() = 'end-time-offset' or name() = 'media-file')]"
					/>
				</xsl:when>
				<!-\\- If there is no Note field starting with \in, then use the values already present in attributes on the segments.
					i.e. There is NO USER override whatsoever. This will only occur with FLExText files that did NOT
					have Notes added (by this XSLT) before IMPORT into FieldWorks. There is no manual addition of Note \in and there
					is no prior automated addition of Note \in either. -\\->
				<xsl:otherwise>
					<xsl:copy-of select="@*"/>
				</xsl:otherwise>
			</xsl:choose>-\->
			<!-\-<xsl:if test="starts-with(item[@type = 'note'], '\in ')">
				<xsl:copy-of
					select="@*[not(name() = 'begin-time-offset' or name() = 'end-time-offset' or name() = 'media-file')]"
				/>	
			</xsl:if>-\->
			<!-\-<xsl:copy-of select="@*"/>-\->
			<xsl:apply-templates/>
			<!-\-<xsl:if test="not(starts-with(item[@type = 'note'], '\in '))">
				<item type="note" lang="en">
					<xsl:text>\in </xsl:text>
					<xsl:value-of select="@begin-time-offset/1000"/>
					<xsl:text> \out </xsl:text>
					<xsl:value-of select="@end-time-offset/1000"/>
					<xsl:if test="$vPOS = 1">
						<xsl:text> \sf </xsl:text>
						<xsl:value-of select="//media[@guid = $vMediaFileGUID]/@location"/>
					</xsl:if>
				</item>
			</xsl:if>-\->
		</xsl:copy>
		<!-\- 
		<media-files offset-type="">
      <media guid="1849cdee-b3d6-4fc1-8c87-4d48788be413" location="C:\Users\sylsk\OneDrive\Documents\SayMore\Kenzi_Sylvia\Sessions\Nori\Nori_Source.wav" />
      <media guid="e814e723-4bf4-487f-9d71-2cc925f7c462" location="C:\Users\sylsk\OneDrive\Documents\SayMore\Kenzi_Sylvia\Sessions\Nori\Nori_Source.wav" />
    </media-files>
		-\->

	</xsl:template>-->

	<xsl:template name="media-files">
		<xsl:param name="pMediaFileName"/>
		<xsl:param name="pMediaFileGUID"/>
		<media-files offset-type="">
			<media>
				<xsl:attribute name="guid" select="$pMediaFileGUID"/>
				<xsl:attribute name="location" select="$pMediaFileName"/>
			</media>
		</media-files>
	</xsl:template>

	<!--<xsl:template match="item[@type='note'][starts-with(., '\in')]"/>-->

	<!--<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>-->

</xsl:stylesheet>
