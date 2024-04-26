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
		<xsl:result-document method="xml"
			href="{concat('file:///',$pAbsolutePathToAppDataFolder,'/ToBeIncorporatedBooks.xml')}"
			indent="yes">
			<books>
				<xsl:for-each select="interlinear-text">
					<xsl:sort select="item[@type='comment'][@lang=$pAnalysisLgCode]/."/>
					<!--<xsl:variable name="vNewLine">
				<xsl:text>&#xD;&#xA;</xsl:text>
			</xsl:variable>-->
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
						select=".//item[@type = 'InOut'][contains(., '\sf ')]/normalize-space(substring-before(substring-after(., 'sf '),'\pf '))"/>
					<xsl:variable name="vPictureFileName">
						<xsl:value-of select=".//item[@type = 'InOut'][contains(., '\pf ')]/normalize-space(substring-after(., 'pf '))"/>
					</xsl:variable>
					<xsl:variable name="vAnalysisTitleAbbreviation">
						<!-- Use Abbreviation if there is one, else use the Title -->
						<xsl:choose>
							<xsl:when test="item[@type = 'title-abbreviation'][@lang = 'en']">
								<xsl:value-of
									select="item[@type = 'title-abbreviation'][@lang = 'en']/text()"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="item[@type = 'title'][@lang = 'en']/text()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="vFileNameSFM">
						<xsl:value-of
							select="$vInterlinearTextNum, '_', $vAnalysisTitleAbbreviation, '.sfm'"
						/>
					</xsl:variable>


					<!--RAB AppDef xml for the books.
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
      					<images type="illustration">
        					<image width="598" height="437">image1.jpeg</image>
      					</images>
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
      					<images type="illustration">
        					<image width="598" height="437">image1.jpeg</image>
      					</images>
      				<book-tabs main-type="T">
        					<book-tab type="1">
	        					<filename>testSource.docx</filename>
	        					<source>C:\Users\lhtre\Desktop\testSource.docx</source>
	        					<features type="book">
	        					<feature name="show-chapter-numbers" value="no"/>
	        					</features>
        					</book-tab>
        				</book-tabs>
    				</book>
  			</books>-->


					<xsl:variable name="vBookID">
						<xsl:value-of
							select="concat($vInterlinearTextNum, '_', $vAnalysisTitleAbbreviation)"
						/>
					</xsl:variable>
					<xsl:variable name="vPictureFileName">
						<!-- substring-before(substring-after(item[@type = 'InOut'], '\in '), '\out')-->
						<xsl:value-of select=".//item[@type = 'InOut'][contains(., '\pf ')]/substring-after(.,'\pf ')"/>
					</xsl:variable>
					<book>
						<xsl:attribute name="id" select="$vBookID"/>
						<name>
							<xsl:value-of select="$vVernacularTextTitle"/>
						</name>
						<abbrev>
							<xsl:value-of select="$vAnalysisTitleAbbreviation"/>
						</abbrev>
						<font-choice type="book-collection"/>
						<filename>
							<xsl:value-of select="concat($vBookID, '.sfm')"/>
						</filename>
						<source>
							<xsl:value-of
								select="concat($pAbsolutePathToAppDataFolder, '\_sfm\', $vBookID, '.sfm')"
							/>
						</source>
						
						
						<!-- <audio chapter="1">
							<filename src="a1" len="78890" size="1895133">the_man_who_turned_to_stone.mp3</filename>
							<timing-filename>04_ManToStone_timings.txt</timing-filename>
						</audio>-->
						<xsl:if test="string-length($vMediaFileName)> 0">
							<audio chapter="1">
								<filename src="a1" len="" size="">
									<xsl:attribute name="len">
										<xsl:value-of select="document(concat('file:///',$pAbsolutePathToAppDataFolder,'\audio\audio_report.xml'))//File[@Name=$vMediaFileName]/DurationMillis"/>
									</xsl:attribute>
									<xsl:attribute name="size">
										<xsl:value-of select="document(concat('file:///',$pAbsolutePathToAppDataFolder,'\audio\audio_report.xml'))//File[@Name=$vMediaFileName]/SizeBytes"/>
									</xsl:attribute>
									<xsl:value-of
										select="concat($pAbsolutePathToAppDataFolder, '\_audio\', $vMediaFileName)"
									/>
								</filename>
								<timing-filename>
									<xsl:value-of select="concat($vBookID, '_timings.txt')"/>
								</timing-filename>
							</audio>
							<audio chapter="2">
								<filename src="a1" len="" size="">
									<xsl:attribute name="len">
										<xsl:value-of select="document(concat('file:///',$pAbsolutePathToAppDataFolder,'\audio\audio_report.xml'))//File[@Name=$vMediaFileName]/DurationMillis"/>
									</xsl:attribute>
									<xsl:attribute name="size">
										<xsl:value-of select="document(concat('file:///',$pAbsolutePathToAppDataFolder,'\audio\audio_report.xml'))//File[@Name=$vMediaFileName]/SizeBytes"/>
									</xsl:attribute>
									<xsl:value-of
										select="concat($pAbsolutePathToAppDataFolder, '\_audio\', $vMediaFileName)"
									/>
								</filename>
								<timing-filename>
									<xsl:value-of select="concat($vBookID, '_timings.txt')"/>
								</timing-filename>
							</audio>
						</xsl:if>
						<!--<xsl:if test="string-length($vPictureFileName)> 0">
							<images type="illustration">
								<image width="" height=""><xsl:value-of select="$vPictureFileName"/></image>
								<!-\-<image width="" height=""><xsl:value-of select="concat($pAbsolutePathToAppDataFolder,'images\illustrations\',$vPictureFileName)"/></image>-\->
							</images>
						</xsl:if>-->
						
						<!-- <book-tabs main-type="T">
						        <book-tab type="1">
						          <filename>testSource.docx</filename>
						          <source>C:\Users\lhtre\Desktop\testSource.docx</source>
						          <features type="book">
						            <feature name="show-chapter-numbers" value="no"/>
						          </features>
						        </book-tab>
						      </book-tabs> -->
					
					
					<book-tabs main-type="T">
						<book-tab type="1">
							<filename><xsl:value-of
								select="concat($vBookID, '_srctab.sfm')"
							/>
							</filename>
							<features type="book">
								<feature name="show-chapter-numbers" value="no"/>
							</features>
						</book-tab>
					</book-tabs>
					</book>
				</xsl:for-each>
			</books>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>
