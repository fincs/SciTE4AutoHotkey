/* * * * * * * * * * * * * * * * * * * * * *
 *                                         *
 *   GenDocs 2.1 SciTE version             *
 *      Template.ahk - This file contains  *
 *         the documentation template.     *
 *   This file is part of GenDocs 2.1      *
 * * * * * * * * * * * * * * * * * * * * * *
 */

charset := A_IsUnicode ? "utf-8" : "iso-8859-1"

template =
(LTrim Join`r`n
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>[FuncName]</title>
<meta http-equiv="Content-Type" content="text/html; charset=%charset%">
<link href="commands.css" rel="stylesheet" type="text/css">
<link href="print.css" rel="stylesheet" type="text/css" media="print">
</head>
<body>

<h1>[FuncName]</h1>
<hr size="2">
<p>[Description]</p>

<p class="CommandSyntax">[Syntax]</p>
<h4>Parameters</h4>
[ParamTable]
<h4>Return Value</h4>
[ReturnValue]
<h4>Remarks</h4>
<p>[Remarks]</p>
<h4>Related</h4>
<p>[LinksToRelatedPages]</p>
<h4>Example</h4>
<pre class="NoIndent">[Example]</pre>

</body>
</html>
)

ptemplate =
(LTrim Join`r`n
<table border="1" width="100`%" cellspacing="0" cellpadding="3" bordercolor="#C0C0C0">
[ParamTable]
</table>
)

tabletemplate =
(LTrim Join`r`n
  <tr>
    <td width="15`%">[ParamName]</td>
    <td width="85`%"><p>[ParamDescription]</p></td>
  </tr>
)

css_commands =
(LTrim Join`r`n
body {
	font-family: Verdana, Arial, Helvetica, sans-serif, "MS sans serif";
	font-size: 75`%;
	border: 0;
	background-color: #FFFFFF;
}

p {
	margin-top: 0.7em;
	margin-bottom: 0.7em;
}
.CodeCom {color: #00A000;}
.NoIndent {
	margin-left: 0;
	margin-right: 0;
}
pre {
	font-family: Verdana, Arial, Helvetica, sans-serif, "MS sans serif";
	font-size: 100`%;
    background-color: #F3F3FF;
	margin: 0.7em 1.5em 0.7em 1.5em;
	padding: 0.7em 0 0.7em 0.7em;
}

table {font-size: 100`%;}
tr {font-size: 100`%;}
td {font-size: 100`%;}
b {font-weight: bold;}
ul {margin-top: 0.7em; margin-bottom: 0.7em;}
ol {margin-top: 0.7em; margin-bottom: 0.7em;}
li {margin-top: 0.2em; margin-bottom: 0.2em;}

a        {text-decoration: none;}
a:link   {text-decoration: none; color: #0000AA;}
a:visited{text-decoration: none; color: #AA00AA;}
a:active {text-decoration: none; color: #0000AA;}
a:hover  {text-decoration: underline; color: #6666CC;}

h1 {
	font-size: 155`%;
	font-weight: normal;
	margin: 0;
}

h2 {
	font-size: 144`%;
	font-weight: bold;
	font-family: Arial, Helvetica, sans-serif, "MS sans serif";
	background-color: #405871;
	color: #FFFFFF;
	margin: 1.0em 0 0.5em 0;
	padding: 0.1em 0 0.1em 0.2em;
}

h4 {
	font-size: 111`%;
	font-weight: bold;
	background-color:#E6E6E6;
	margin: 1.0em 0 0.5em 0;
	padding: 0.1em 0 0.1em 0.2em;
}

p.CommandSyntax {
	background-color: #FFFFAA;
	margin: 0 0 1.0em 0;
	padding: 12px 0 12px 4px;
}

.red {color: #DD0000;}
.green {color: #006030;}
.greenbold {color: #006030;	font-weight: bold;}
.small80bold {font-size: 80`%; font-weight: bold}
.small80 {font-size: 80`%; font-weight: normal}
.small65 {font-size: 65`%; font-weight: normal}
)

css_print =
(LTrim Join`r`n
* { font-family: "Times New Roman", Times, serif; }
a {
	font-family: inherit;
	color: #000;
	font-style: oblique;
	background: inherit;
}
p { line-height: 1.5; }
li { line-height: 1.3; }
h2, h4 { border-bottom: 1px solid #333; }
h4 {
	font-size: x-large;
	font-weight: normal;
}
body table:first-child, body table:first-child + hr, pre + hr, pre + hr + p { display: none; }
.CommandSyntax {
	font-size: xx-large;
	background: #fbfbfb;
	padding-left: .3em;
}
pre {
	background: #fafafa;
	margin-left: 1em;
	padding: .5em;
	border: 1px solid #ccc;
}
.CodeCom {
	font-weight: bold;
	background: inherit;
}
pre, .CommandSyntax, .CodeCom {
	font-family: "Andale Mono", "Courier New", Courier, monospace;
	color: inherit;
}
table {
	border-collapse: collapse;
	border-top: 1px solid #ccc;
	border-right: 1px solid #ccc;
	border-bottom: none;
	border-left: 1px solid #ccc;
}
td {
	margin: .2em;
	width: auto;
	padding: .4em;
	border-bottom: 1px solid #ccc;
	border-top-style: none;
	border-right-style: none;
	border-left-style: none;
}
table p { margin: 0em; }
table p + p { margin-top: 1em; }
tr td:first-child {
	vertical-align: top;
	text-decoration: underline;
	background: #fcfcfc;
	padding-left: 1em;
	padding-right: 1em;
	color: inherit;
}
)