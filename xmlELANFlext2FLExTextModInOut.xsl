<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	exclude-result-prefixes="xs" version="3.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<!-- Larry Hayashi March 20 2024 -->
	<xsl:param name="pVernacularLgCode"/>
	<xsl:param name="pAnalysisLgCode"/>
	<xsl:param name="pMediaFileName"/>
	
	<xsl:param name="pOffSetType">
		<!-- Possible values: AUD - Audacity - Seconds.decimal_places
			ELAN - Hours:Min:Seconds.Decimal_places-->
	</xsl:param>
	<xsl:template match="document">
		<!--<xsl:variable name="vRandom-seed" select="random-number-generator()"/>-->
		<!--<xsl:variable name="vRandom-seed" select="generate-id()"/>-->
		<xsl:variable name="vRandom-number" select="generate-id()"/>
		<!--<xsl:variable name="vRandom-number"
			select="format-number(($vRandom-seed('permute')((current-dateTime() - xs:dateTime('1970-01-01T00:00:00Z')) div xs:dayTimeDuration('PT1S')) mod 10000000), '0000000')"/>-->
		<xsl:variable name="vMediaFileGUID" select="$vRandom-number"/>
		<!-- Sometimes a flextext file will contain multiple flextexts from different texts inside the project.
			Each one might have its own associated sound or video file.
			So here, we crawl through the entire flextext <document>
			looking for each <interlinear-text>.
			We get the sound file listed, usually in the 1st segment of the text in the InOut field with a \sf.-->
		<xsl:for-each select="interlinear-text">
			<xsl:variable name="vTextTitle" select="item[@type='title'][@lang=$pVernacularLgCode]/text()"/>
			<xsl:result-document method="xml"
				href="{concat($vTextTitle,'.flextext')}" indent="yes">
				<document>
					<xsl:copy-of select="../@*"/>
					<interlinear-text>
						<!--<xsl:variable name="vMediaFileName" select="paragraphs/paragraph/phrases/phrase/item[@type='InOut'][contains(text(),'\sf ')]/substring-after(text(), 'sf ')"/>-->
						<!--<xsl:variable name="vMediaFileName"
							select=".//item[@type = 'InOut'][contains(., '\sf ')]/substring-after(., 'sf ')"/>-->

						<xsl:copy-of select="@*"/>
						<xsl:apply-templates>
							<xsl:with-param name="pMediaFileGUID" select="$vMediaFileGUID"/>
						</xsl:apply-templates>
						<xsl:call-template name="media-files">
							<xsl:with-param name="pMediaFileGUID" select="$vMediaFileGUID"/>
							<xsl:with-param name="pMediaFileName" select="$vMediaFileName"/>
						</xsl:call-template>
					</interlinear-text>
				</document>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="phrase">
		<xsl:param name="pMediaFileGUID"/>
		<!-- vPOS stores the position of the current phrase among phrases-->
		<xsl:variable name="vPOS">
			<xsl:number count="phrase" level="any" format="1"/>
		</xsl:variable>
		<!--<xsl:variable name="vMediaFileName" select="normalize-space(substring-before(substring-after(concat(item[@type = 'note'], '\'), '\sf '), '\'))"/>-->
		<xsl:copy>
			<!--The goal of this transform is to have reconciled user-edited offsets (captured in Notes on text segments
				with the attributes on phrase xml in FLExText.-->
			<!-- If there is a custom field InOut with the segment then
				copy the value of the \in to begin-time-offset
				copy the value of the \out to end-time-offset
				and if there is \sf then copy to media-file attribute-->
			<!-- The user can modify the InOut data if needed
				so this transform copies the InOut data over any existing data in these begin-time-offset and end-time-offset.-->
			<!--If for some reason there is no InOut custom field but there are @begin-time-offset and end-time-offset
				then create an InOut custom field with those offsets stored as \in, \out and \sf.-->
			<!-- Floor() rounds down to nearest integer.-->


			<!-- Export / Copy InOut custom field data to begin-time-offset and end-time-offset 
			Use pOffSetType to determine conversion. The FLExText format expects total milliseconds -->
			<xsl:if test="item[@type = 'InOut']">
				<xsl:variable name="vInOffSet">
					
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$pOffSetType = 'AUD'">
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
					</xsl:when>
					<xsl:when test="$pOffSetType='ELAN'">
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
					</xsl:when>
				</xsl:choose>
				<xsl:attribute name="media-file" select="$pMediaFileGUID"/>
			</xsl:if>
			
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="media-files"/><!-- Destroys original media-files elements-->

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

	<xsl:template match="*">
		<!-- Declare the parameter so it can be used within this template -->
		<xsl:param name="pMediaFileGUID"/>

		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates>
				<!-- Pass the parameter to the next level of applied templates -->
				<xsl:with-param name="pMediaFileGUID" select="$pMediaFileGUID"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
