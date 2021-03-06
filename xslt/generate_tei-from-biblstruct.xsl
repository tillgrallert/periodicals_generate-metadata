<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- param to toggle certain links -->
    <xsl:param name="p_file-local" select="true()"/>
    
    <xsl:variable name="v_source-url" select="base-uri()"/>
    <xsl:variable name="v_base-url" select="'https://github.com/openarabicpe/newspaper_al-asr-al-jadid/blob/master/tei/'"/>
    <xsl:variable name="v_id-facs" select="'facs_'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tei:text/descendant::tei:biblStruct" mode="m_generate-tei"/>
    </xsl:template>
    
    <xsl:template match="tei:biblStruct" mode="m_generate-tei">
        <xsl:variable name="v_oclc" select="tei:monogr/tei:idno[@type='OCLC'][1]"/>
        <xsl:variable name="v_issue" select="number(tei:monogr/tei:biblScope[@unit='issue']/@from)"/>
        <xsl:variable name="v_volume" select="number(tei:monogr/tei:biblScope[@unit='volume']/@from)"/>
        <xsl:variable name="v_date" select="tei:monogr/tei:imprint/tei:date[@when][1]/@when"/>
        <xsl:variable name="v_id" select="if(@xml:id) then(@xml:id) else(generate-id())"/>
        <!-- full identifier of this publication, usually oclc_\d+ -->
        <xsl:variable name="v_publication-id" select="concat('oclc_',$v_oclc)"/>
        <xsl:variable name="v_file-name" select="concat($v_publication-id,'-i_',$v_issue)"/>
        <xsl:result-document href="../_output/xml/{$v_file-name}.TEIP5.xml">
            <!-- link schema and TEI boilerplate -->
            <xsl:text disable-output-escaping="yes">&lt;?xml-model href="https://openarabicpe.github.io/OpenArabicPE_ODD/schema/tei_periodical.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?></xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;?xml-model href="https://openarabicpe.github.io/OpenArabicPE_ODD/schema/tei_periodical.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?></xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;?xml-model href="https://openarabicpe.github.io/OpenArabicPE_ODD/schema/tei_periodical.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?></xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;?xml-stylesheet type="text/xsl" href="https://openarabicpe.github.io/tei-boilerplate-arabic-editions/boilerplate/xslt/teibp_parameters.xsl"?&gt;</xsl:text>
            <tei:TEI xml:id="{$v_file-name}">
                <!-- add @next and @prev: data type is data.pointer, which means a full URI. In our case this should link to a XML file -->
                <xsl:if test="$v_issue &gt; 1">
                    <xsl:attribute name="prev" select="concat($v_publication-id,'-i_',$v_issue - 1,'.TEIP5.xml')"/>
                </xsl:if>
                <xsl:attribute name="next" select="concat($v_publication-id,'-i_',$v_issue + 1,'.TEIP5.xml')"/>
                <!-- generate teiHeader -->
                <xsl:call-template name="t_generate-teiHeader">
                    <xsl:with-param name="p_input" select="."/>
                    <xsl:with-param name="p_file-name" select="$v_file-name"/>
                </xsl:call-template>
                <tei:facsimile>
                    <xsl:call-template name="t_generate-facsimile">
                        <xsl:with-param name="p_page-start" select="number(tei:monogr/tei:biblScope[@unit='page']/@from)"/>
                        <xsl:with-param name="p_page-stop" select="number(tei:monogr/tei:biblScope[@unit='page']/@to)"/>
                        <xsl:with-param name="p_path-file" select="concat('../images/',$v_publication-id,'-i_',$v_issue,    '-p_')"/>
                    </xsl:call-template>
                </tei:facsimile>
                <tei:text xml:lang="ar">
                    <xsl:call-template name="t_generate-pb">
                        <xsl:with-param name="p_page-start" select="number(tei:monogr/tei:biblScope[@unit='page']/@from)"/>
                        <xsl:with-param name="p_page-stop" select="number(tei:monogr/tei:biblScope[@unit='page']/@from)"/>
                    </xsl:call-template>
                    <front/>
                    <tei:body>
                        <tei:div type="item">
                        <xsl:call-template name="t_generate-pb">
                            <xsl:with-param name="p_page-start" select="number(tei:monogr/tei:biblScope[@unit='page']/@from)+1"/>
                            <xsl:with-param name="p_page-stop" select="number(tei:monogr/tei:biblScope[@unit='page']/@to)"/>
                        </xsl:call-template>
                        </tei:div>
                    </tei:body>
                </tei:text>
            </tei:TEI>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="t_generate-teiHeader">
        <xsl:param name="p_input"/>
        <xsl:param name="p_file-name"/>
        <tei:teiHeader xml:lang="en">
            <tei:fileDesc>
                <tei:titleStmt>
                    <title>
                        <xsl:value-of select="$p_input/tei:monogr/tei:title[@level='j'][@xml:lang='ar-Latn-x-ijmes'][1]"/>
                        <!-- issue -->
                        <xsl:text> #</xsl:text>
                        <xsl:value-of select="$p_input/tei:monogr/tei:biblScope[@unit='issue']/@from"/>
                        <!-- date -->
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="format-date($p_input/tei:monogr/tei:imprint/tei:date[1]/@when,'[D1] [MNn] [Y0001]')"/>
                    </title>
                    <title type="sub">TEI edition</title>
                    <!-- responsibilities -->
                    <respStmt xml:lang="en">
                        <resp>TEI edition</resp>
                        <persName xml:id="pers_TG">Till Grallert</persName>
                    </respStmt>
                </tei:titleStmt>
                <tei:publicationStmt>
                    <authority> 
                        <persName>Till Grallert</persName>
                    </authority>
                    <pubPlace>Beirut</pubPlace>
                    <date when="{format-date(current-date(),'[Y0001]')}"><xsl:value-of select="format-date(current-date(),'[Y0001]')"/></date>
                    <availability status="restricted">
                        <licence target="http://creativecommons.org/licenses/by-sa/4.0/">Distributed under a Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) license</licence>
                    </availability>
                    <idno type="url"><xsl:value-of select="concat($v_base-url,$p_file-name,'.TEIP5.xml')"/></idno>
                </tei:publicationStmt>
                <tei:sourceDesc>
                    <xsl:copy-of select="$p_input"/>
                </tei:sourceDesc>
            </tei:fileDesc>
            <tei:revisionDesc>
                <tei:change when="{format-date(current-date(),'[Y0001]-[M01]-[D01]')}">Created this file by automatic conversion of <tei:gi>biblStruct</tei:gi> from <xsl:value-of select="$v_source-url"/>.</tei:change>
            </tei:revisionDesc>
        </tei:teiHeader>
    </xsl:template>
    
    <!-- generate the facsimile -->
    <xsl:template name="t_generate-facsimile">
        <xsl:param name="p_page-start" select="1"/>
        <xsl:param name="p_page-stop" select="4"/>
        <xsl:param name="p_path-file"/>
        <xsl:element name="tei:surface">
            <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start)"/>
            <xsl:if test="$p_file-local = true()">
                <!-- the addition of files should depend on the actual availability of file -->
                <xsl:variable name="v_image-url" select="concat($p_path-file,format-number($p_page-start,'0'),'.jpg')"/>
                <xsl:if test="fs:exists(fs:new(resolve-uri($v_image-url, base-uri(.))))" xmlns:fs="java.io.File">
                    <!--<xsl:message>
                        <xsl:value-of select="$v_image-url"/><xsl:text> exists</xsl:text>
                    </xsl:message>-->
                    <xsl:element name="tei:graphic">
                        <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_1')"/>
                        <xsl:attribute name="url" select="$v_image-url"/>
                        <xsl:attribute name="mimeType" select="'image/jpeg'"/>
                    </xsl:element>
                </xsl:if>
                <xsl:variable name="v_image-url" select="concat($p_path-file,format-number($p_page-start,'0'),'-color.jpg')"/>
                <xsl:if test="fs:exists(fs:new(resolve-uri($v_image-url, base-uri(.))))" xmlns:fs="java.io.File">
                    <xsl:element name="tei:graphic">
                        <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_2')"/>
                        <xsl:attribute name="url" select="$v_image-url"/>
                        <xsl:attribute name="mimeType" select="'image/jpeg'"/>
                    </xsl:element>
                </xsl:if>
                <!-- tiffs -->
                <xsl:variable name="v_image-url" select="concat($p_path-file,format-number($p_page-start,'0'),'.tif')"/>
                <xsl:if test="fs:exists(fs:new(resolve-uri($v_image-url, base-uri(.))))" xmlns:fs="java.io.File">
                    <xsl:element name="tei:graphic">
                        <xsl:attribute name="xml:id" select="concat($v_id-facs,$p_page-start,'-g_3')"/>
                        <xsl:attribute name="url" select="$v_image-url"/>
                        <xsl:attribute name="mimeType" select="'image/tiff'"/>
                    </xsl:element>
                </xsl:if>
            </xsl:if>
        </xsl:element>
        <xsl:if test="$p_page-start lt $p_page-stop">
            <xsl:call-template name="t_generate-facsimile">
                <xsl:with-param name="p_page-start" select="$p_page-start +1"/>
                <xsl:with-param name="p_page-stop" select="$p_page-stop"/>
                <xsl:with-param name="p_path-file" select="$p_path-file"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="t_generate-pb">
        <xsl:param name="p_page-start"/>
        <xsl:param name="p_page-stop"/>
        <xsl:element name="tei:pb">
            <xsl:attribute name="ed" select="'print'"/>
            <xsl:attribute name="n" select="$p_page-start"/>
            <xsl:attribute name="facs" select="concat('#',$v_id-facs,$p_page-start)"/>
        </xsl:element>
        <xsl:if test="$p_page-start lt $p_page-stop">
            <xsl:call-template name="t_generate-pb">
                <xsl:with-param name="p_page-start" select="$p_page-start +1"/>
                <xsl:with-param name="p_page-stop" select="$p_page-stop"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>