<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:import href="../../Teinte/xsl/toc.xsl"/>
  <xsl:import href="../../Teinte/xsl/flow.xsl"/>
  <xsl:import href="../../Teinte/xsl/notes.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" omit-xml-declaration="no"/>
  <xsl:variable name="split" select="true()"/>
  <xsl:key name="split" match="
    tei:*[self::tei:div or self::tei:div1 or self::tei:div2][normalize-space(.) != ''][@type][
    contains(@type, 'article') 
    or contains(@type, 'chapter') 
    or contains(@subtype, 'split') 
    or contains(@type, 'act')  
    or contains(@type, 'poem')
    or contains(@type, 'letter')
    ] 
    | tei:group/tei:text 
    | tei:TEI/tei:text/tei:*/tei:*[self::tei:div or self::tei:div1 or self::tei:group or self::tei:titlePage  or self::tei:castList][normalize-space(.) != '']" 
  use="generate-id(.)"/>
  <xsl:param name="bookpath"/>
  <xsl:param name="package"/>
  <xsl:variable name="_html"/>
  <xsl:variable name="title_j">
    <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]/tei:title[@level='j']" mode="title"/>
  </xsl:variable>
  <xsl:template match="/" priority="10">
    <concrete5-cif version="1.0">
      <pages>
        <xsl:for-each select="//tei:div[@type='article']">
          <xsl:call-template name="article"/>
        </xsl:for-each>
      </pages>
    </concrete5-cif>
  </xsl:template>
  <xsl:template name="article">
    <xsl:variable name="divid">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <xsl:variable name="date">
      <xsl:variable name="text" select="substring-before(concat(@xml:id, '_'), '_')"/>
      <xsl:value-of select="translate(@xml:id, 'abcdefghijklmnopqrstuvwxyz', '')"/>
    </xsl:variable>
    <xsl:variable name="name">
      <xsl:variable name="rich">
        <xsl:apply-templates select="." mode="title"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    <xsl:variable name="meta_title">
      <xsl:variable name="rich">
        <xsl:apply-templates select="tei:head" mode="title"/>
        <xsl:text> – </xsl:text>
        <xsl:copy-of select="$title_j"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    <page path="{$bookpath}/{$divid}" name="{$name}" package="{$package}" template="liseuse" pagetype="liseuse">
      <attributes>
        <attributekey handle="doctype">
          <value>Article</value>
        </attributekey>
        <attributekey handle="meta_title">
          <value>
            <xsl:value-of select="$meta_title"/>
          </value>
        </attributekey>
      </attributes>
      <area name="Main">
        <blocks>
          <block type="content">
            <data table="btContentLocal">
              <record>
                <content>
                  <article>
                    <xsl:apply-templates>
                      <xsl:with-param name="level" select="1"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="footnotes">
                      <!--
                      <xsl:with-param name="pb" select="NONODE"/>
                      -->
                    </xsl:call-template>
                  </article>
                </content>
              </record>
            </data>
          </block>
        </blocks>
      </area>
      <area name="Sidebar">
        <blocks>
          <block type="content" name="toc">
            <data table="btContentLocal">
              <record>
                <content>
                  <xsl:call-template name="toclocal"/>
                </content>
              </record>
            </data>
          </block>

            <!--
          <block type="autonav" name="autonav">
            <data table="btNavigation">
              <record>
                <orderBy>display_asc</orderBy>
                <displayPages>current</displayPages>
                <displayPagesCID/>
                <displayPagesIncludeSelf>0</displayPagesIncludeSelf>
                <displaySubPages>none</displaySubPages>
                <displaySubPageLevels>enough</displaySubPageLevels>
                <displaySubPageLevelsNum>0</displaySubPageLevelsNum>
                <displayUnavailablePages>0</displayUnavailablePages>
              </record>
            </data>
          </block>
          -->
        </blocks>
      </area>
    </page>
  </xsl:template>
  <!-- numéro de note par chapitre -->
  <xsl:template name="note-n">
    <xsl:variable name="resp" select="@resp"/>
    <xsl:choose>
      <xsl:when test="@resp='editor'">
        <xsl:number count="tei:note[@resp=$resp]" format="a" from="tei:div[@type='article']" level="any"/>
      </xsl:when>
      <xsl:when test="@resp">
        <xsl:number count="tei:note[@resp=$resp]" from="tei:div[@type='article']" level="any"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number count="tei:note[not(@resp) and not(@rend) and not(@place='margin') and not(parent::tei:div) and not(parent::tei:notesStmt)]" from="tei:div[@type='article']" level="any"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Identifiant local -->
  <xsl:template match="tei:div[@type = 'article']" mode="id">
    <xsl:choose>
      <xsl:when test="contains(@xml:id, '_')">
        <xsl:value-of select="translate(substring-before(@xml:id, '_'), 'abcdefghijklmnopqrstuvwxyz', '')"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="substring-after(@xml:id, '_')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(@xml:id, 'abcdefghijklmnopqrstuvwxyz', '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
