<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  xmlns:tei="http://www.tei-c.org/ns/1.0"  exclude-result-prefixes="tei">
  <xsl:import href="../../Teinte/xsl/toc.xsl"/>
  <xsl:import href="../../Teinte/xsl/flow.xsl"/>
  <xsl:import href="../../Teinte/xsl/notes.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" omit-xml-declaration="no"/>
  <xsl:param name="bookpath"/>
  <xsl:param name="package"/>
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
  <xsl:variable name="_html"></xsl:variable>
  <xsl:variable name="bibl">
    <xsl:apply-templates select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/node()"/>
  </xsl:variable>
  

  
  <xsl:template match="/" priority="10">
    <concrete5-cif version="1.0">
      <pages>
        <xsl:for-each select="//tei:div[@type='chapter']">
          <xsl:call-template name="chapter"/>
        </xsl:for-each>
      </pages>
    </concrete5-cif>
  </xsl:template>
  
  <xsl:template name="chapter">
    <xsl:variable name="chapid">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <!--
    <xsl:variable name="title">
      <xsl:variable name="rich">
        <xsl:copy-of select="$doctitle"/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$docdate"/>
        <xsl:text>) </xsl:text>
        <xsl:for-each select="ancestor-or-self::*">
          <xsl:sort order="descending" select="position()"/>
          <xsl:choose>
            <xsl:when test="self::tei:TEI"/>
            <xsl:when test="self::tei:text"/>
            <xsl:when test="self::tei:body"/>
            <xsl:otherwise>
              <xsl:if test="position() != 1"> — </xsl:if>
              <xsl:apply-templates mode="title" select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    -->
    <xsl:variable name="name">
      <xsl:variable name="rich">
        <xsl:apply-templates select="." mode="title"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    <xsl:variable name="booktitle">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$docdate"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of select="$doctitle"/>
      <xsl:text>)</xsl:text>
    </xsl:variable>   
    <page path="{$bookpath}/{$chapid}" name="{$name}" package="{$package}" template="liseuse" pagetype="liseuse">
      <attributes>
        <attributekey handle="doctype">
          <value>Chapter</value>
        </attributekey>
        <!--  TODO ?
        <attributekey handle="bookid">
          <value>
            <xsl:value-of select="$bookid"/>
          </value>
        </attributekey>
        -->
        <attributekey handle="meta_title">
          <value>
            <xsl:value-of select="$name"/>
            <xsl:value-of select="$booktitle"/>
          </value>
        </attributekey>
        <attributekey handle="meta_ld">
          <value>
{
  "@context": "https://schema.org/",
  "@type": "BreadcrumbList",
  "itemListElement": [{
    "@type": "ListItem",
    "position": 1,
    "name": "Rougemont",
    "item": {
      "@id": "https://www.unige.ch/rougemont/",
      "@type": "Person"
    }
  },{
    "@type": "ListItem",
    "position": 2,
    "name": "<xsl:value-of select="$doctitle"/> (<xsl:value-of select="$docdate"/>)",
    "item": {
      "@id": "https://www.unige.ch/rougemont<xsl:value-of select="$bookpath"/>",
      "@type": "Book"
    }
  },{
    "@type": "ListItem",
    "position": 3,
    "name": "<xsl:value-of select="$name"/>"
  }]
}
          </value>
        </attributekey>
        <xsl:if test="tei:div">
          <attributekey handle="meta_description">
            <value>
              <xsl:for-each select=".//tei:div">
                <xsl:variable name="subhead">
                  <xsl:call-template name="title"/>
                </xsl:variable>
                <xsl:value-of select="normalize-space($subhead)"/>
                <xsl:if test="position() != last()"> – </xsl:if>
              </xsl:for-each>
            </value>
          </attributekey>
          <attributekey handle="subheads">
            <value>
              <xsl:for-each select=".//tei:div">
                <xsl:variable name="subhead">
                  <xsl:call-template name="title"/>
                </xsl:variable>
                <xsl:call-template name="id"/>
                <xsl:value-of select="$tab"/>
                <xsl:value-of select="normalize-space($subhead)"/>
                <xsl:value-of select="$booktitle"/>
                <xsl:value-of select="$lf"/>
              </xsl:for-each>
            </value>
          </attributekey>
        </xsl:if>
      </attributes>
      <area name="Main">
        <blocks>
          <block type="content">
            <data table="btContentLocal">
              <record>
                <content>
                  <article role="article">
                    <xsl:apply-templates>
                      <xsl:with-param name="level" select="1"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="footnotes"/>
                  </article>
                </content>
              </record>
            </data>
          </block>
        </blocks>
      </area>
      <area name="Sidebar">
        <blocks>
          <block type="content" name="">
            <data table="btContentLocal">
              <record>
                <content>
                  <xsl:call-template name="toclocal"/>
                </content>
              </record>
            </data>
          </block>
        </blocks>
      </area>
    </page>
  </xsl:template>

  <!-- Identifiant local -->
  <xsl:template match="tei:div[@type = 'chapter']" mode="id">
    <xsl:number level="any" count="tei:div[@type = 'chapter']"/>
  </xsl:template>
  
  
  <!-- a prev/next navigation -->
  <xsl:template name="prevnext">
    <nav class="prevnext">
      <div class="prev">
        <xsl:for-each select="preceding::*[@type='chapter'][1]">
          <xsl:variable name="title">
            <xsl:call-template name="title"/>
          </xsl:variable>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="normalize-space($title)"/>
            </xsl:attribute>
            <xsl:copy-of select="$title"/>
          </a>
        </xsl:for-each>
        <xsl:text> </xsl:text>
      </div>
      <div class="next">
        <xsl:text> </xsl:text>
        <xsl:for-each select="following::*[@type='chapter'][1]">
          <xsl:variable name="title">
            <xsl:call-template name="title"/>
          </xsl:variable>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="normalize-space($title)"/>
            </xsl:attribute>
            <xsl:copy-of select="$title"/>
          </a>
        </xsl:for-each>
      </div>
    </nav>
  </xsl:template>
</xsl:transform>
