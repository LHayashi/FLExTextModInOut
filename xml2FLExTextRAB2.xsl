<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	exclude-result-prefixes="xs" version="3.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<!-- Larry Hayashi March 20 2024 -->
	<xsl:param name="pVernacularLgCode"/>
	<xsl:param name="pAnalysisLgCode"/>
	<xsl:param name="pAbsolutePathToAppDataFolder"/>
	<!-- Possible values: AUD - Audacity - Seconds.decimal_places
			ELAN - Hours:Min:Seconds.Decimal_places-->
	<xsl:param name="pOffSetType"/>

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
			<xsl:sort select="item[@type='comment'][@lang=$pAnalysisLgCode]"/>
			<xsl:variable name="vNewLine">
				<xsl:text>&#xD;&#xA;</xsl:text>
			</xsl:variable>
			<xsl:variable name="vInterlinearTextNum">
				<xsl:number count="interlinear-text" level="any" format="01"/>
			</xsl:variable>
			<xsl:variable name="vVernacularTextTitle"
				select="item[@type = 'title'][@lang = $pVernacularLgCode]/text()"/>
			<xsl:variable name="vAnalysisTextTitle"
				select="item[@type = 'title'][@lang = $pAnalysisLgCode]/text()"/>
			<xsl:variable name="vAnalysisSourceInfo">
				<xsl:value-of select="item[@type = 'source'][@lang = 'en']"/>
			</xsl:variable>
			<xsl:variable name="vMediaFileName"
				select=".//item[@type = 'InOut'][contains(., '\sf ')]/normalize-space(substring-before(substring-after(., 'sf '),'\pf'))"/>
			<xsl:variable name="vPictureFileName">
				<!-- substring-before(substring-after(item[@type = 'InOut'], '\in '), '\out')-->
				<xsl:value-of select=".//item[@type = 'InOut'][contains(., '\pf ')]/normalize-space(substring-after(.,'\pf '))"/>
			</xsl:variable>
			<xsl:variable name="vAnalysisTitleAbbreviation">
				<!-- Use Abbreviation if there is one, else use the Title -->
				<xsl:choose>
					<xsl:when test="item[@type = 'title-abbreviation'][@lang = 'en']">
						<xsl:value-of
							select="item[@type = 'title-abbreviation'][@lang = 'en']/text()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="item[@type = 'title'][@lang = 'en']/text()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			
			<!-- RAB AppDef Books generation 
				<books>
				<book id="B003-2">
      					<name>MWTTS</name>
					<abbrev>MWTTSAbbreviation</abbrev>
      					<font-choice type="book-collection" />
      					<filename>MWTTS.sfm</filename>
      					<source>C:\Users\lhtre\Desktop\temp2\RABOutputs\MWTTS.sfm</source>

      					<audio chapter="1">
        					<filename src="a1" len="78890" size="1895133">C:\Users\lhtre\Desktop\temp2\AudioFiles\the_man_who_turned_to_stone.mp3</filename>
        					<timing-filename>05_ManToStone_timings_alpha.txt</timing-filename>
      					</audio>
    				</book>
    				<book id="$vBookID">
      					<name>$vVernacularTextTitle</name>
      					<abbrev>$vAnalysisTitleAbbreviation</abbrev>
      					<font-choice type="book-collection" />
      					<filename>$vBookID.sfm</filename>
      					<source>$pAbsolutePathToAppDataFolder\_sfm\$vBookID.sfm</source>

      					<audio chapter="1">
        					<filename src="a1" len="?78890" size="?1895133">$pAbsolutePathToAppDataFolder\_audio\$vMediaFileName</filename>
        					<timing-filename>$vBookID_timings.txt</timing-filename>
      					</audio>
    				</book>
  			</books>-->
-->
			
			<!-- RAB USFM file generation
			Stored in: \My Documents\App Builder\Reading Apps\App Projects\Haisla Stories\Haisla Stories_data\books\C01
			Looks like this: 
				\id 14_BigSalmon
				\toc1 qábeskasus JACK I
				\toc2 Big Spring Salmon
				
				\page 1
				\mt1 qábeskasus JACK I
				\mt2 Big Spring Salmon
				\img placeHolderForNow.jpg
				\b
				\m n̓aukʷs hísilaqus lanúxʷ t̓epánuma’in, lálaqia’in qi ’úm̓asgenis qábes.
				\m li t̓ex̄ína…
			-->
			
			<xsl:result-document method="text" href="{concat('file:///',$pAbsolutePathToAppDataFolder,'/_sfm/',$vInterlinearTextNum,'_',$vAnalysisTitleAbbreviation,'.sfm')}" indent="no">				
				<xsl:text>\id </xsl:text><xsl:value-of select="concat($vInterlinearTextNum,'_',$vAnalysisTitleAbbreviation, $vNewLine)"/>
				<!--<xsl:text>\toc1 </xsl:text><xsl:value-of select="concat($vVernacularTextTitle,' (',$vAnalysisTextTitle,')',$vNewLine)"/>-->
				<xsl:text>\toc1 </xsl:text><xsl:value-of select="concat($vVernacularTextTitle,$vNewLine)"/>
				<xsl:text>\toc2 </xsl:text><xsl:value-of select="concat($vAnalysisTextTitle,$vNewLine)"/>
				<xsl:value-of select="$vNewLine"/>
				<xsl:text>\c 1</xsl:text><xsl:value-of select="$vNewLine"/>
				<!--<xsl:text>\mt1 </xsl:text><xsl:value-of select="concat($vVernacularTextTitle,$vNewLine)"/>
				<xsl:text>\mt2 </xsl:text><xsl:value-of select="concat($vAnalysisTextTitle,$vNewLine)"/>-->
				<xsl:text>\m \fig </xsl:text><xsl:value-of select="concat($vPictureFileName,' \fig*',$vNewLine)"/>
				<xsl:text>\b </xsl:text><xsl:value-of select="$vNewLine"/>
				<!--<xsl:text>\s Test</xsl:text><xsl:value-of select="$vNewLine"/>-->
					<!--<xsl:copy-of select="@*"/>-->
					<!--<xsl:apply-templates>
						<xsl:with-param name="pMediaFileGUID" select="$vMediaFileGUID"/>
					</xsl:apply-templates>-->
					<!--<xsl:call-template name="media-files">
						<xsl:with-param name="pMediaFileGUID" select="$vMediaFileGUID"/>
						<xsl:with-param name="pMediaFileName" select="$vMediaFileName"/>
					</xsl:call-template>-->
				<xsl:apply-templates select="paragraphs/paragraph" mode="sfm"/>
				
				
				<xsl:text>\c 2</xsl:text><xsl:value-of select="$vNewLine"/>
				<!--<xsl:text>\mt1 </xsl:text><xsl:value-of select="concat($vVernacularTextTitle,$vNewLine)"/>
				<xsl:text>\mt2 </xsl:text><xsl:value-of select="concat($vAnalysisTextTitle,$vNewLine)"/>-->
				<xsl:text>\m \fig </xsl:text><xsl:value-of select="concat($vPictureFileName,' \fig*',$vNewLine)"/>
				<xsl:text>\b </xsl:text><xsl:value-of select="$vNewLine"/>
				<xsl:apply-templates select="paragraphs/paragraph" mode="sfm_with_free"/>
			</xsl:result-document>
				
			
			<!-- RAB Timing Files generation 
			Stored in: \My Documents\App Builder\Reading Apps\App Projects\Haisla Stories\Haisla Stories_data\timings
			Looks like this:  
				0.000002	9.180842	1
				9.180842	17.638135	2
				17.638135	20.785916	3-->
			<xsl:result-document method="text" href="{concat('file:///',$pAbsolutePathToAppDataFolder,'/timings/',$vInterlinearTextNum,'_',$vAnalysisTitleAbbreviation,'_timings.txt')}" indent="no">								
				<xsl:apply-templates select="paragraphs/paragraph/phrases/phrase" mode="timingFiles"/>
			</xsl:result-document>
			
			<!-- RAB Phrase Files generation 
			Stored in: \My Documents\App Builder\Reading Apps\Phrases\org.hncfnef.stories.haisla
			Filename like this: C01-19-19_WeegitsRock-01.phrases (C01-textNumber-NameOfSFMFILE-01.phrases)
			Look like this: 
				1a	winásus ’ebúkʷs saak
				1b	Attacked by a Mama Grizzly
				1c	kakat̓ánumanukʷ náasdaq du henḡáaq [du] sex̄ém, ’émɫem m̓ásdems kakat̓ásunukʷ.
				1d	[li] y̓ex̄ʷelaláisin qi la t̓álix̄i DALA-RIVER-ax̄i, la geldálix̄i.-->
			<xsl:result-document method="text" href="{concat('C01-',$vInterlinearTextNum,'-',$vInterlinearTextNum,'_',$vAnalysisTitleAbbreviation,'-01.phrases')}" indent="no">								
				<xsl:apply-templates select="paragraphs/paragraph/phrases/phrase" mode="phraseFiles"/>
			</xsl:result-document>
			
			<!-- RAB SrcTab files generation 
				<item type="title" lang="en">Oolichan Harvest</item>
				<item type="title" lang="has">zázaw̓a’ini</item>
				<item type="title-abbreviation" lang="en">OolichanHarvest</item>
				<item type="source" lang="en">Ella Grant - The following núyem was originally recorded by Hein Vink sometime in the 1970's; it was subsequently transcribed and translated by Emmon Bach with the help of Dora Robinson and Rose Robinson for use in Wisenis X̄X̄a’islak’ala! Beginning Haisla: Lessons 1–10 (1995), a course that Bach taught through UNBC. It has been updated to fit modern orthography with some small corrections to the original text (both in transcription and translation).</item>
				<item type="comment" lang="en">24 Unk-Raw</item>
				
				\id 01_Prayer
				\c 1 
				\m The following núyem was taken from Haisla! etc.
			-->
			<xsl:result-document method="text" href="{concat('file:///',$pAbsolutePathToAppDataFolder,'/books/C01/',$vInterlinearTextNum,'_',$vAnalysisTitleAbbreviation,'/',$vInterlinearTextNum,'_',$vAnalysisTitleAbbreviation,'_srctab.sfm')}" indent="no">								
				<xsl:text>\id </xsl:text><xsl:value-of select="$vInterlinearTextNum,'_',$vAnalysisTitleAbbreviation"/><xsl:text>&#xD;&#xA;</xsl:text>
				<xsl:text>\c 1</xsl:text><xsl:text>&#xD;&#xA;</xsl:text>
				<xsl:text>\m </xsl:text><xsl:value-of select="item[@type='title'][@lang=$pVernacularLgCode]/text()"/><xsl:text>&#xD;&#xA;</xsl:text>
				<xsl:text>\m </xsl:text><xsl:value-of select="item[@type='title'][@lang=$pAnalysisLgCode]/text()"/><xsl:text>&#xD;&#xA;</xsl:text>
				<xsl:text>\b</xsl:text><xsl:text>&#xD;&#xA;</xsl:text>
				<xsl:text>\m </xsl:text><xsl:value-of select="item[@type='source'][@lang=$pAnalysisLgCode]/text()"/><xsl:text>&#xD;&#xA;</xsl:text>
			</xsl:result-document>
			
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="paragraphs/paragraph" mode="sfm">
		<!--<xsl:text>\p </xsl:text><xsl:text>&#xD;&#xA;</xsl:text> <!-\- CR followed by LF -\->-->
		<xsl:apply-templates select="phrases/phrase/item[@type = 'txt']" mode="sfm"/>
	</xsl:template>
	
	<xsl:template match="paragraphs/paragraph" mode="sfm_with_free">
		<!--<xsl:text>\p </xsl:text><xsl:text>&#xD;&#xA;</xsl:text> <!-\- CR followed by LF -\->-->
		<xsl:apply-templates select="phrases/phrase/item[@type = 'txt']" mode="sfm_with_free"/>
	</xsl:template>

	<xsl:template match="phrases/phrase/item[@type = 'txt']" mode="sfm">
		<!--<xsl:variable name="vPhraseNumber" select="../item[@type='segnum']/."/>-->
		<xsl:variable name="vPhraseNumber">
			<xsl:number count="item[@type='segnum']" level="any" format="1"/>
		</xsl:variable>
		
		<!--<xsl:value-of select="concat('\v ',$vPhraseNumber,' ')"/>-->
		<xsl:value-of select="concat('\m ',text(),'&#xD;&#xA;')"/>
		<!--<xsl:value-of select="text()"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<xsl:text>\m </xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>-->
		<!-- CR followed by LF -->
	</xsl:template>
	
	<xsl:template match="phrases/phrase/item[@type = 'txt']" mode="sfm_with_free">
		<!--<xsl:variable name="vPhraseNumber" select="../item[@type='segnum']/."/>-->
		<xsl:variable name="vPhraseNumber">
			<xsl:number count="item[@type='segnum']" level="any" format="1"/>
		</xsl:variable>
		
		<!--<xsl:value-of select="concat('\v ',$vPhraseNumber,' ')"/>-->
		<xsl:value-of select="concat('\m ',text(),'&#xD;&#xA;')"/>
		<xsl:for-each select="following-sibling::item[@type='gls']|preceding-sibling::item[@type='gls']">
			<xsl:value-of select="concat('\b ','&#xD;&#xA;')"/>
			<xsl:value-of select="concat('\it ',text(),'\it*','&#xD;&#xA;')"/>
		</xsl:for-each>
		
		<!--<xsl:value-of select="text()"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<xsl:text>\m </xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>-->
		<!-- CR followed by LF -->
	</xsl:template>
	
	<xsl:template match="paragraphs/paragraph/phrases/phrase" mode="timingFiles">
		<xsl:param name="pMediaFileGUID"/>
		
		<!-- vPOS stores the position of the current phrase among phrases-->
		<xsl:variable name="vPhraseNumber" select="item[@type='segnum']/."/>
		<xsl:variable name="vAlphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:variable name="vIndex" select="number($vPhraseNumber)"/>
		<!-- Calculate the phrase letter a, b, c ... z, aa, ab, ac ... az, ba, bb, bc ... etc.-->
		<xsl:variable name="vPhraseLetter">
			<xsl:choose>
				<xsl:when test="$vIndex le 26">
					<!-- Single letter (first cycle through the alphabet) -->
					<xsl:value-of select="substring($vAlphabet, $vIndex, 1)"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- Repeated letter (second cycle through the alphabet) -->
					<xsl:value-of select="substring($vAlphabet, floor((($vIndex - 1) div 26) - 1) + 1, 1)"/>
					<xsl:value-of select="substring($vAlphabet, (($vIndex - 1) mod 26) + 1, 1)"/>
				</xsl:otherwise>
			</xsl:choose>
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
				<xsl:variable name="vBeginTimeOffset">
					<xsl:value-of
						select="number(normalize-space(substring-before(substring-after(item[@type = 'InOut'], '\in '), '\out')))"
					/>
				</xsl:variable>
				<xsl:variable name="vEndTimeOffset">
						<xsl:value-of
							select="number(normalize-space(substring-before(substring-after(concat(item[@type = 'InOut'], '\'), '\out '), '\')))"
						/>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$pOffSetType = 'AUD'">
						<xsl:value-of select="concat($vBeginTimeOffset,'&#x9;',$vEndTimeOffset,'&#x9;',$vPhraseLetter,'&#xD;&#xA;')"/>
					</xsl:when>
					<xsl:when test="$pOffSetType='ELAN'"><xsl:text>Placeholder</xsl:text>
					</xsl:when>
				</xsl:choose>
				<!--<xsl:attribute name="media-file" select="$pMediaFileGUID"/>-->
			
<!--			<xsl:apply-templates/>-->
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="paragraphs/paragraph/phrases/phrase" mode="phraseFiles">
		<xsl:param name="pMediaFileGUID"/>
		
		<!-- vPOS stores the position of the current phrase among phrases-->
		<xsl:variable name="vPhraseNumber" select="item[@type='segnum']/."/>
		<!--<xsl:variable name="vMediaFileName" select="normalize-space(substring-before(substring-after(concat(item[@type = 'note'], '\'), '\sf '), '\'))"/>-->
		<xsl:copy>
			<xsl:value-of select="concat($vPhraseNumber,'&#x9;',item[@type = 'txt'][@lang=$pVernacularLgCode]/text(),'&#xD;&#xA;')"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="VernacularTextTitle"
		match="item[@type = 'title'][@lang = $pVernacularLgCode]">
		<xsl:text>\pc </xsl:text>
		<xsl:value-of select="item[@type = 'title'][@lang = 'en']"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<!-- CR followed by LF -->
	</xsl:template>

	<xsl:template name="AnalysisTextTitle" match="item[@type = 'title'][@lang = $pAnalysisLgCode]">
		<xsl:text>\pc </xsl:text>
		<xsl:value-of select="item[@type = 'title'][@lang = 'en']"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<!-- CR followed by LF -->
	</xsl:template>

	<xsl:template name="AnalysisSourceInfo" match="item[@type = 'source'][@lang = $pAnalysisLgCode]">
		<xsl:text>\pc </xsl:text>
		<xsl:value-of select="item[@type = 'title'][@lang = 'en']"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<!-- CR followed by LF -->
	</xsl:template>




	<xsl:template match="media-files"/>
	<!-- Destroys original media-files elements-->

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
