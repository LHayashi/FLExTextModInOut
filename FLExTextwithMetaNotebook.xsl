<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- Apply this xslt to the fwdata file 
    Currently extracts metadata from the RnGenericRecord associated with a text in FLEx 
    Will eventually incorporate this metadata into the FLExText export -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="pTextGUID"/>
    <xsl:key name="rtByGuid" match="rt" use="@guid"/>
    
    
    <!--Find the RnGenericRecord that refers to the pTextGUID
        <rt class="RnGenericRec" guid="78edb73d-2a80-402b-b6f2-844141e51e53" ownerguid="d739cbea-ea5e-11de-85be-0013722f8dec">
        ...
            <Text>
                <objsur guid="a899ecf0-9ede-4820-b716-ed78b746854f" t="r" />
            </Text>
    -->
    <xsl:template match="/">
        <xsl:for-each select="//rt[@class = 'RnGenericRec'][Text/objsur[@guid = $pTextGUID]]">
            <xsl:variable name="vRnGenericRecordGUID" select="@guid"/>
            <xsl:for-each select="key('rtByGuid', $vRnGenericRecordGUID)">
                <xsl:call-template name="GenericRecord"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="GenericRecord">
        <nb-record-metadata>
            <xsl:attribute name="textGUID" select="$pTextGUID"/>
            <xsl:attribute name="rnRecordGUID" select="@guid"/>
            <xsl:copy-of select="DateCreated|DateModified|DateOfEvent|Title"/>
            <xsl:apply-templates select="Researchers|Sources|Participants"/>
            <xsl:apply-templates select="Locations|Location|PlaceOfBirth|PlacesOfResidence"/>
            <xsl:apply-templates select="AnthroCodes"/>
        </nb-record-metadata>
    </xsl:template>
     
    
    
    <xsl:template name="Locations" match="Locations|Location|PlaceOfBirth|PlacesOfResidence">
        <xsl:element name="{name()}">        
            <xsl:apply-templates select="objsur"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="AnthroCodes" match="AnthroCodes">
        <xsl:element name="{name()}">        
            <xsl:apply-templates select="objsur"/>
        </xsl:element>
    </xsl:template>
       
    <xsl:template name="StdListItemData" match="objsur">
        <!--Includes Class Name Abbreviation Description guid for possibility lists
            Applies additional templates based on class for unique fields-->
        <xsl:variable name="guid" select="@guid"/>
        <xsl:variable name="rtElement" select="key('rtByGuid', @guid)"/>
        <xsl:for-each select="$rtElement">
            <!-- Do something with each child element -->
            <xsl:element name="{@class}">
                <xsl:apply-templates select="Name"/>
                <xsl:apply-templates select="Abbreviation"/>
                <xsl:apply-templates select="Description"/>
               
               <xsl:choose>
                   <xsl:when test="@class='CmPerson'">
                       <xsl:apply-templates select="PlacesOfResidence|Locations|Location|PlaceOfBirth"/>       
                   </xsl:when>
                   <xsl:when test="@class='CmLocation'">
                       <!--Other elements on CmLocation can be output here-->       
                   </xsl:when>
                   <xsl:when test="@class='CmAnthroItem'">
                       <!--Other elements on CmAnthroItem can be output here-->       
                   </xsl:when>
                   <xsl:otherwise>testotherwise</xsl:otherwise>
               </xsl:choose>
                
            </xsl:element>
        </xsl:for-each>
        <!--Depending on the parent of objsur, additional information is added below-->
        <!--<xsl:copy-of select="DateOfBirth|DateofDeath"/>-->
        <!--<xsl:apply-templates select="Location|PlaceOfBirth|PlaceOfResidence"/>-->
    </xsl:template>
    
    
    
    

    <!-- Default template to copy any other elements or text -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
