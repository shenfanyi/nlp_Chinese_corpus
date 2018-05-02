<?xml version="1.0" encoding="gb2312"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/REC-html40">
<xsl:template match="/">
	<html xmlns:v="urn:schemas-microsoft-com:vml">
	<head>
	<title>HIT IR-Lab LTP</title>
	<style>
	v\:*{behavior:url(#default#VML);}
	body,table{font-size:12pt;}
	font:title{font-size:12pt;}
	</style>
	
	<script language="javascript">
	
	stylesheet=document.XSLDocument;
	source=document.XMLDocument;
	
	function choose(x) //ѡ��ģ�鲢������ʾ
	{
		apply=stylesheet.selectSingleNode('//xsl:template[@match="xml4nlp"]/xsl:apply-templates/@select');
		mode=stylesheet.selectSingleNode("//@mode");
		if(x == "sum" || x == "class")
		{
			apply.value=x;
			mode.value="origin";
		}
		else
		{
			apply.value="doc";
			mode.value=x;
		}
		
		bodytag.innerHTML=source.documentElement.transformNode(stylesheet);
		chooseform.item.value=x;
		
		if(x == "coref")
		{
			display_coref();
		}
		
		if(x == "nerecog")
		{
			display_nehead();
		}

		if(x == "all")
		{
			output.innerHTML = '<p><strong style="color:blue">ѡ��Ҫ��ʾ��ģ�飺</strong>\
			<input type="checkbox" checked="on" name="isPOS"/>���Ա�ע\
			<input type="checkbox" checked="on" name="isWSD"/>��������\
			<input type="checkbox" checked="on" name="isNE"/>����ʵ��\
			<input type="checkbox" checked="on" name="isSRL"/>�������\
			<input type="checkbox" checked="on" name="isParser"/>�䷨����\
			</p><hr/>';
		}
	}
	
	function setPOS()
	{
	}

	function display_nehead() //��ʾNEʶ���ͷ����Ϣ
	{
		output.innerHTML='<p><font color="green">��������ɫ</font>��\
			<font color="olive">���������ɫ</font>��\
			<font color="blue">����������ɫ</font>��\
			<font color="orange">ʱ�䣺��ɫ</font>��\
			<font color="purple">���ڣ���ɫ</font>��\
			<font color="red">���ʣ���ɫ</font>��\
			<font color="brown">ר�����ʣ���ɫ</font></p><hr/>';
	}

	function display_parser(pid, sid) //��ʾ��pid�ε�sid����﷨������Ϣ
	{
		var para = source.selectSingleNode('//para[@id=' + pid + ']');
	    var sent = para.selectSingleNode('sent[@id=' + sid + ']');
	    var wordNum=sent.childNodes.length; //�����дʵĸ���
		var parentArray = new Array();
		var relateArray = new Array();
		var maxWidth = 0; //��������ȣ�Ϊ��ȷ��ͼ�εĸ߶�
		var maxWordLen = 0;
		
		for(var i = 0; i != wordNum; i++) //�˴�������С�ں�
		{
			var word = sent.childNodes.item(i);
			parentArray[i] = word.getAttribute("parent");
			relateArray[i] = word.getAttribute("relate");
			if(parentArray[i] == -1) //����Ǻ��Ĵʽ�㣬�����ĸ������Ϊ������Ϊ�ھ���ĩβ���ϵ�EOS���
				parentArray[i] = wordNum;
				
			var wordCont = word.getAttribute( "cont" );
			var wordLen = wordCont.length;
			if ( wordCont.match( /\w+/ ) )	// English letter
			{
				wordLen /= 2;
			}			
			maxWordLen = Math.max(wordLen, maxWordLen);
			if(parentArray[i] != -2 )
				maxWidth = Math.max(Math.abs(parentArray[i]-i), maxWidth);
		}
		
		var textleft;
		var texttop = maxWidth*8 + 40; //���־��ϱߵľ���
		var textheight = maxWordLen*20 + 20;	// maxWordLen to determine the height of the output
		var tree = '';

		for(var j = 0; j != wordNum; j++)
		{
			var word = sent.childNodes.item(j).getAttribute("cont");
			textleft = j * 40;
			tree += '<font style="color:blue;position:absolute;top:' + texttop + ';left:' + textleft + ';width:20;word-break:break-all;align:center;vertical-align:text-top;">' + word + '</font>';  // width:40
		}
		textleft = wordNum * 40;
		tree += '<font style="color:blue;position:absolute;top:' + texttop + ';left:' + textleft + ';width:20;word-break:break-all;align:center;vertical-align:text-top;">EOS</font>';

		var arcwidth = 0;
		var archeight = 0;
		var arctop = 0; //���߾��ϱߵľ���
		var arcleft = 0;

		for(var k = 0; k != parentArray.length; k++)
		{
			if(parentArray[k] != -2)
			{
				var endarrow;
				var startpoint = Math.min(parentArray[k], k);
				if(startpoint == k)
				{
					endarrow = true;
					arcleft = startpoint * 40 + 8;
				}
				else
				{
					endarrow = false;
					arcleft = startpoint * 40 + 13;
				}
				
				arcwidth = Math.abs(parentArray[k]-k) * 40 - 5;
				archeight = 2*(arcwidth / 5 + 10);
				arctop = texttop-archeight/2-2; //���߾��ϱߵľ���
				tree += '<v:arc fillcolor="white" style="position:absolute;left:' + arcleft + ';top:' + arctop + ';width:' + arcwidth + ';height:' + archeight + ';" startangle="-90" endangle="90">';
				tree += '<v:fill type="frame" opacity="0"/>';
				if(endarrow)
					tree += '<v:stroke color="blue" opacity="5" startarrow="none" endarrow="classic"/>';
				else
					tree += '<v:stroke color="blue" opacity="5" startarrow="classic" endarrow="none"/>';
				tree += '</v:arc>';

				var relateleft;
				var relatetop = arctop - 5.5;
				var recttop = arctop - 2;
				var rectwidth;
				if(relateArray[k].length == 3)
				{
					rectwidth = 20;
					relateleft = arcleft + arcwidth/2 - 11;
				}
				else
				{
					rectwidth = 13;
					relateleft = arcleft + arcwidth/2 - 7;
				}
				if(relateArray[k] != '-')
				{
					tree += '<v:roundrect style="position:absolute;left:' + relateleft + ';width:' + rectwidth + ';top:' + recttop + ';height:4" strokecolor="white" arcsize="0.2" fillcolor="white"/>';
					tree += '<font style="font-size:11px;position:absolute;color:red;top:' + relatetop + ';left:' + relateleft + '">' + relateArray[k] + '</font>';
				}
			}
		}
		
		var parserDiv=document.getElementById(pid+"_"+sid+"_parser");
		parserDiv.style.height =  texttop + textheight;
	    parserDiv.innerHTML = tree;

	    var oEventObj=event.srcElement;
	    if(parserDiv.style.display=="none")
	    {
		   	parserDiv.style.display="";
		   	oEventObj.value="��";
		   	
		   	
		}
		else
		{
		    parserDiv.style.display="none";
		    oEventObj.value="��";
		}
	}

	function display_srl(pid, sid) //��ʾ��pid�ε�sid������������Ϣ
	{
	    var para = source.selectSingleNode('//para[@id=' + pid + ']');
	    var sent = para.selectSingleNode('sent[@id=' + sid + ']');
	    var wordNum=sent.childNodes.length; //�����дʵĸ���
	    
	    var body="";
		for(var i = 0; i != wordNum; i++) //�˴�������С�ں�
		{
			var word = sent.childNodes.item(i);
			body += "<td>" + word.getAttribute("cont") + "</td>";
		}

		body = '<tr bgcolor="white">' + body + '</tr>';

		for(var k = 0; k != wordNum; k++)
		{
			var word = sent.childNodes.item(k);
			if(word.childNodes.length != 0) //�ô���һ��ν��
			{
				var tr=""; //table�е�һ��
				var argNum = word.childNodes.length; //argument�ĸ���
				var basecount = 0; //�൱��һ����ʱ�ļ�����
				for(var j = 0; j != argNum; j++)
				{
					var arg = word.childNodes.item(j);
					var beg = arg.getAttribute("beg");
					var end = arg.getAttribute("end");
					var colspan = end-beg+1; //argument������ռ��table������
					var type = arg.getAttribute("type");

					//���argument֮ǰ������argument֮��Ĳ���
					for(var m = basecount; m != beg; m++)
					{
						if(m == k) //����һ��ν��
							tr += '<td bgcolor="yellow">ν��</td>';
						else
							tr += "<td></td>"
					}
					//���argument����
					tr += '<td align="center" bgcolor="lightblue" colspan="' + colspan + '">' + type + '</td>';
					basecount = end-0+1; //�ȼ�һ��0��Ϊ��ʹend���ַ�������תΪ��������
				}
				
				//������һ��argument����ʣ��Ĳ���
				for(var n = basecount; n != wordNum; n++)
				{
					if(n == k)
						tr += '<td bgcolor="yellow">ν��</td>';
					else
						tr += "<td></td>"
				}

				tr = '<tr align="center" bgcolor="white">' + tr + '</tr>';
				body += tr;
			}
		}
		
	    var srlDiv=document.getElementById(pid+"_"+sid+"_srl");
	    srlDiv.innerHTML = '<table border="0" cellpadding="5" cellspacing="1" bgcolor="black">' + body + '</table>';

	    var oEventObj=event.srcElement;
	    if(srlDiv.style.display=="none")
	    {
		   	srlDiv.style.display="";
		   	oEventObj.value="��";
		}
		else
		{
		    srlDiv.style.display="none";
		    oEventObj.value="��";
		}
	}
	
	function display_coref() //��ʾָ��������Ϣ
	{
		var begArray = new Array(); //���ÿ��mention��beg����
		var endArray = new Array(); //���ÿ��mention��end����
		var crArray = new Array(); //���ÿ��mention�ĸ�����id����
		var mentionArray = source.getElementsByTagName("mention");
		var mentionNum = mentionArray.length;
		for(var j = 0; j != mentionNum; j++)
		{
			var mention = mentionArray.item(j);
			begArray[j] = mention.getAttribute("beg");
			endArray[j] = mention.getAttribute("end");
			crArray[j] = mention.selectSingleNode("..").getAttribute("id");
		}
		
		var doc = "";
		var paraArray = source.getElementsByTagName("para");
		var paraNum = paraArray.length;
		var accumWordIndex = 0; //�ۼƵĴʵ�����
		
		for(var i = 0; i != paraNum; i++)
		{
			var wordArray = paraArray.item(i).getElementsByTagName("word");
			var para = '<p>';
			var wordNum = wordArray.length; //��ǰ����Ĵʵ�����
			for(var j = 0; j != wordNum; j++, accumWordIndex++)
			{
				var word = wordArray.item(j).getAttribute('cont');
				for(var k = 0; k != mentionNum; k++)
				{
					//�˴�ʵ���Ǳ��ʽ��accumWordIndex == begArray[k] AND accumWordIndex == endArray[k]�������ڲ��ܳ����߼�����ţ���˲��ô˵ȼ�ʽ
					if(!(!(accumWordIndex == begArray[k]) || !(accumWordIndex == endArray[k]))) 
					{
						para += '<font color="blue">' + word + '</font>' + '<strong style="color:red;vertical-align:super;font-size:10pt;">' + crArray[k] + '</strong>' + ' ';
						break;
					}
					else if( accumWordIndex == begArray[k])
					{
						para += '<font color="blue">' + word + ' ';
						break;
					}
					else if(accumWordIndex == endArray[k])
					{
						para += word + '</font>' + '<strong style="color:red;vertical-align:super;font-size:10pt;">' + crArray[k] + '</strong>' + ' ';
						break;
					}
				}
				if(k == mentionNum) 
					para += word + ' ';
			}
			para += '</p>';
			doc += para;
		}
		output.innerHTML = doc;		
	}
	

	function display_all(pid, sid) //��ʾ��pid�ε�sid���ȫ����Ϣ
	{
	    var para = source.selectSingleNode('//para[@id=' + pid + ']');
	    var sent = para.selectSingleNode('sent[@id=' + sid + ']');
	    var wordNum=sent.childNodes.length; //�����дʵĸ���
	    
	    var body="";
		for(var i = 0; i != wordNum; i++) //�˴�������С�ں�
		{
			var word = sent.childNodes.item(i);
			body += "<td>" + word.getAttribute("cont") + "</td>";
		}
		body = '<tr bgcolor="white" align="center">' + body + '</tr>';

		if(isPOS.checked) //������Ա�ע��Ϣ
		{
			body += '<tr bgcolor="white" align="center">';
			for(var a = 0; a != wordNum; a++) 
			{
				var pos = sent.childNodes.item(a).getAttribute("pos");
				body += '<td style="color:blue;">' + pos + "</td>";
			}
			body += '</tr>';
		}

		if(isWSD.checked) //�������������Ϣ
		{
			body += '<tr bgcolor="white" align="center">';
			for(var b = 0; b != wordNum; b++) 
			{
				var wsd = sent.childNodes.item(b).getAttribute("wsd");
				var wsdexp = sent.childNodes.item(b).getAttribute("wsdexp");
				body += '<td style="color:blue;" title="' + wsdexp + '">' + wsd + "</td>";
			}
			body += '</tr>';
		}

		if(isNE.checked) //�������ʵ��ʶ����Ϣ
		{
			body += '<tr bgcolor="white" align="center">';
			for(var i = 0; i != wordNum; i++) 
			{
				var ne = sent.childNodes.item(i).getAttribute("ne");
				if(ne.search(/Nm/) != -1)
				{
					var colspan = 1;
					for(var j = i+1; j != wordNum; j++)
					{
						var ne = sent.childNodes.item(j).getAttribute("ne");
						if(ne.search(/Nm/) != -1)
							colspan++;
						else
							break;
					}
					i = j-1;
					body += '<td bgcolor="lightyellow" style="color:red" colspan="' + colspan + '">����</td>';
				}
				else if(ne.search(/Ni/) != -1)
				{
					var colspan = 1;
					for(var j = i+1; j != wordNum; j++)
					{
						var ne = sent.childNodes.item(j).getAttribute("ne");
						if(ne.search(/Ni/) != -1)
							colspan++;
						else
							break;
					}
					i = j-1;
					body += '<td bgcolor="lightyellow" style="color:blue" colspan="' + colspan + '">������</td>';
				}
				else if(ne.search(/Ns/) != -1)
				{
					var colspan = 1;
					for(var j = i+1; j != wordNum; j++)
					{
						var ne = sent.childNodes.item(j).getAttribute("ne");
						if(ne.search(/Ns/) != -1)
							colspan++;
						else
							break;
					}
					i = j-1;
					body += '<td bgcolor="lightyellow" style="color:olive" colspan="' + colspan + '">����</td>';
				}
				else if(ne.search(/Nh/) != -1)
				{
					var colspan = 1;
					for(var j = i+1; j != wordNum; j++)
					{
						var ne = sent.childNodes.item(j).getAttribute("ne");
						if(ne.search(/Nh/) != -1)
							colspan++;
						else
							break;
					}
					i = j-1;
					body += '<td bgcolor="lightyellow" style="color:green" colspan="' + colspan + '">����</td>';
				}
				else if(ne.search(/Nt/) != -1)
				{
					var colspan = 1;
					for(var j = i+1; j != wordNum; j++)
					{
						var ne = sent.childNodes.item(j).getAttribute("ne");
						if(ne.search(/Nt/) != -1)
							colspan++;
						else
							break;
					}
					i = j-1;
					body += '<td bgcolor="lightyellow" style="color:orange" colspan="' + colspan + '">ʱ��</td>';
				}
				else if(ne.search(/Nr/) != -1)
				{
					var colspan = 1;
					for(var j = i+1; j != wordNum; j++)
					{
						var ne = sent.childNodes.item(j).getAttribute("ne");
						if(ne.search(/Nr/) != -1)
							colspan++;
						else
							break;
					}
					i = j-1;
					body += '<td bgcolor="lightyellow" style="color:purple" colspan="' + colspan + '">����</td>';
				}
				else if(ne.search(/Nz/) != -1)
				{
					var colspan = 1;
					for(var j = i+1; j != wordNum; j++)
					{
						var ne = sent.childNodes.item(j).getAttribute("ne");
						if(ne.search(/Nz/) != -1)
							colspan++;
						else
							break;
					}
					i = j-1;
					body += '<td bgcolor="lightyellow" style="color:brown" colspan="' + colspan + '">ר��</td>';
				}
				else
				{
					body += '<td style="color:blue;"></td>';
				}
			}
			
			body += '</tr>';
		}

	var SRLNum = 0;
	if(isSRL.checked) //������������Ϣ
	{

		for(var k = 0; k != wordNum; k++)
		{
			var word = sent.childNodes.item(k);
			if(word.childNodes.length != 0) //�ô���һ��ν��
			{
				++SRLNum;
				
				var tr=""; //table�е�һ��
				var argNum = word.childNodes.length; //argument�ĸ���
				var basecount = 0; //�൱��һ����ʱ�ļ�����
				for(var j = 0; j != argNum; j++)
				{
					var arg = word.childNodes.item(j);
					var beg = arg.getAttribute("beg");
					var end = arg.getAttribute("end");
					var colspan = end-beg+1; //argument������ռ��table������
					var type = arg.getAttribute("type");

					//���argument֮ǰ������argument֮��Ĳ���
					for(var m = basecount; m != beg; m++)
					{
						if(m == k) //����һ��ν��
							tr += '<td bgcolor="yellow">ν��</td>';
						else
							tr += "<td></td>"
					}
					//���argument����
					tr += '<td align="center" bgcolor="lightblue" colspan="' + colspan + '">' + type + '</td>';
					basecount = end-0+1; //�ȼ�һ��0��Ϊ��ʹend���ַ�������תΪ��������
				}
				
				//������һ��argument����ʣ��Ĳ���
				for(var n = basecount; n != wordNum; n++)
				{
					if(n == k)
						tr += '<td bgcolor="yellow">ν��</td>';
					else
						tr += "<td></td>"
				}

				tr = '<tr align="center" bgcolor="white">' + tr + '</tr>';
				body += tr;
			}
		}

	}

	var tree = '';
	if(isParser.checked) //����䷨������Ϣ
	{
		var para = source.selectSingleNode('//para[@id=' + pid + ']');
	    var sent = para.selectSingleNode('sent[@id=' + sid + ']');
	    var wordNum=sent.childNodes.length; //�����дʵĸ���
		var parentArray = new Array();
		var relateArray = new Array();
		var maxWidth = 0; //��������ȣ�Ϊ��ȷ��ͼ�εĸ߶�
		var maxWordLen = 0;

		for(var i = 0; i != wordNum; i++) //�˴�������С�ں�
		{
			var word = sent.childNodes.item(i);
			parentArray[i] = word.getAttribute("parent");
			relateArray[i] = word.getAttribute("relate");
			if(parentArray[i] == -1) //����Ǻ��Ĵʽ�㣬�����ĸ������Ϊ������Ϊ�ھ���ĩβ���ϵ�EOS���
				parentArray[i] = wordNum;
			
			var wordCont = word.getAttribute( "cont" );
			var wordLen = wordCont.length;
			if ( wordCont.match( /\w+/ ) )	// English letter
			{
				wordLen /= 2;
			}			
			maxWordLen = Math.max(wordLen, maxWordLen);
			
			if(parentArray[i] != -2 )
				maxWidth = Math.max(Math.abs(parentArray[i]-i), maxWidth);
		}
		
		var addHeight = 0;
		if(isPOS.checked)
			addHeight += 20;
		if(isWSD.checked)
			addHeight += 20;
		if(isNE.checked)
			addHeight += 40;
		if(isSRL.checked)
			addHeight += SRLNum*40;

		var textleft;
		var textheight = maxWordLen*20 + 20;
		var texttop = maxWidth*8 + textheight + 40 + addHeight; //���־��ϱߵľ���

		for(var j = 0; j != wordNum; j++)
		{
			var word = sent.childNodes.item(j).getAttribute("cont");
			textleft = j * 40;
			tree += '<font style="color:blue;position:absolute;top:' + texttop + ';left:' + textleft + ';width:20;word-break:break-all;align:center;vertical-align:text-top;">' + word + '</font>';
		}
		textleft = wordNum * 40;
		tree += '<font style="color:blue;position:absolute;top:' + texttop + ';left:' + textleft + ';width:20;word-break:break-all;align:center;vertical-align:text-top;">EOS</font>';

		var arcwidth = 0;
		var archeight = 0;
		var arctop = 0; //���߾��ϱߵľ���
		var arcleft = 0;

		for(var k = 0; k != parentArray.length; k++)
		{
			if(parentArray[k] != -2)
			{
				var endarrow;
				var startpoint = Math.min(parentArray[k], k);
				if(startpoint == k)
				{
					endarrow = true;
					arcleft = startpoint * 40 + 8;
				}
				else
				{
					endarrow = false;
					arcleft = startpoint * 40 + 13;
				}
				
				arcwidth = Math.abs(parentArray[k]-k) * 40 - 5;
				archeight = 2*(arcwidth / 5 + 10);
				arctop = texttop-archeight/2-2; //���߾��ϱߵľ���
				tree += '<v:arc fillcolor="white" style="position:absolute;left:' + arcleft + ';top:' + arctop + ';width:' + arcwidth + ';height:' + archeight + ';" startangle="-90" endangle="90">';
				tree += '<v:fill type="frame" opacity="0"/>';
				if(endarrow)
					tree += '<v:stroke color="blue" opacity="5" startarrow="none" endarrow="classic"/>';
				else
					tree += '<v:stroke color="blue" opacity="5" startarrow="classic" endarrow="none"/>';
				tree += '</v:arc>';

				var relateleft;
				var relatetop = arctop - 5.5;
				var recttop = arctop - 2;
				var rectwidth;
				if(relateArray[k].length == 3)
				{
					rectwidth = 20;
					relateleft = arcleft + arcwidth/2 - 11;
				}
				else
				{
					rectwidth = 13;
					relateleft = arcleft + arcwidth/2 - 7;
				}
				if(relateArray[k] != '-')
				{
					tree += '<v:roundrect style="position:absolute;left:' + relateleft + ';width:' + rectwidth + ';top:' + recttop + ';height:4" strokecolor="white" arcsize="0.2" fillcolor="white"/>';
					tree += '<font style="font-size:11px;position:absolute;color:red;top:' + relatetop + ';left:' + relateleft + '">' + relateArray[k] + '</font>';
				}
			}
		}

	}
		
	    var allDiv=document.getElementById(pid+"_"+sid+"_all");
		var divHeight = texttop + textheight;
		

		if(isParser.checked)
			allDiv.style.height =  divHeight;
		
	    allDiv.innerHTML = tree +  '<table border="0" cellpadding="5" cellspacing="1" bgcolor="black">' + body + '</table>' ;

	    var oEventObj=event.srcElement;
	    if(allDiv.style.display=="none")
	    {
		   	allDiv.style.display="";
		   	oEventObj.value="��";
		}
		else
		{
		    allDiv.style.display="none";
		    oEventObj.value="��";
		}
	}
	
	</script>
	
	</head>
	<body>
	
	<div id="bodytag">
		<xsl:apply-templates select="xml4nlp"/>
	</div>
	
	</body>
	</html>
</xsl:template>


<xsl:template match="xml4nlp">
	<!--�����б�����ѡ��Ҫ��ʾ��ģ��-->
	<form name="chooseform" method = "post" action = "Try.py">
	<font color="blue" size="2" align="center">ע�⣺���ڱ�Demo֧��IE��MyIE��Maxthon���������֧��Firefox��Mozilla��NetScape.  </font>
	<font color="red" size="2">����ͽ����뷢���� <A target="_blank"><xsl:attribute name="HREF">./MessageBoard/index.asp<xsl:value-of select="Url"/></xsl:attribute><xsl:value-of select="ir.hit.edu.cn"/>HIT IR-Lab LTP ���԰�</A></font>
	<hr />
	<font color="red"><b>ѡ����ʾ���ݣ�</b></font>
	<select name="item" value="origin" onchange="choose(this.value)">
		<option value="origin">ԭʼ�ı�</option>
		<option value="wordseg">�ִ�</option>
		<option value="postag">���Ա�ע</option>
		<option value="nerecog">����ʵ��</option>
		<option value="wsd">��������</option>
		<option value="parser">�䷨����</option>
		<option value="srl">�������</option>
		<option value="coref">ָ������</option>
		<option value="sum">�Զ���ժ</option>
		<option value="class">�ı�����</option>
	</select>
	<!--
	<input type="submit" name="button" value="��ʾ"/>
	-->
	<xsl:text>	</xsl:text>
	<input type="button" value="��������ʾ" onclick="choose('all')"/>
	<xsl:text>	����</xsl:text>
	<font color="red"><b>��ӭʹ��IRLab-NLPMLϵͳ</b></font>
	<xsl:text>	������</xsl:text>
	<input type = "button" value = "�����ı������"  onclick="window.location.href='Try.py'"/><br />
	</form>	
	<hr/>
	<div id="output">
	</div>
	<xsl:apply-templates select="doc"/>
</xsl:template>


<!--�Զ���ժ-->
<xsl:template match="sum">
	<p><b><font color="blue">��ժ��</font></b>
	<xsl:value-of select="."/></p>
	<hr/><br/>
	<b><font color="blue">ԭ�ģ�</font></b>
	<xsl:apply-templates select="//doc"/>
</xsl:template>


<!--�ı�����-->
<xsl:template match="class">
	<p><b><font color="blue">���</font></b>
	<xsl:value-of select="."/></p>
	<hr/><br/>
	<b><font color="blue">ԭ�ģ�</font></b>
	<xsl:apply-templates select="//doc"/>
</xsl:template>


<xsl:template match="doc">
	<xsl:apply-templates select="para"/>
</xsl:template>


<xsl:template match="para">
	<p>
	<xsl:apply-templates select="sent" mode="origin"/>
	</p>
</xsl:template>


<!--ԭʼ�ı�-->
<xsl:template match="sent" mode="origin">
	<xsl:value-of select="@cont"/>
</xsl:template>


<!--�ִ�-->
<xsl:template match="sent" mode="wordseg">
	<xsl:for-each select="word">
		<xsl:value-of select="@cont"/>
		<xsl:text> </xsl:text>
	</xsl:for-each>
</xsl:template>


<!--���Ա�ע-->
<xsl:template match="sent" mode="postag">
	<xsl:for-each select="word">
	    <xsl:value-of select="@cont"/>/<font color="blue">
              <xsl:value-of select="@pos"/></font>
	     <xsl:text>��</xsl:text>
	</xsl:for-each>
</xsl:template>


<!--����ʵ��ʶ��-->
<xsl:template match="sent" mode="nerecog">
	<xsl:for-each select="word">
		<xsl:choose>
			<xsl:when test="contains(@ne, 'Nm')">
				<font color="red"><xsl:value-of select="@cont"/></font>
			</xsl:when>
			<xsl:when test="contains(@ne, 'Ni')">
				<font color="blue"><xsl:value-of select="@cont"/></font>
			</xsl:when>
			<xsl:when test="contains(@ne, 'Ns')">
				<font color="olive"><xsl:value-of select="@cont"/></font>
			</xsl:when>
			<xsl:when test="contains(@ne, 'Nh')">
				<font color="green"><xsl:value-of select="@cont"/></font>
			</xsl:when>
			<xsl:when test="contains(@ne, 'Nt')">
				<font color="orange"><xsl:value-of select="@cont"/></font>
			</xsl:when>
			<xsl:when test="contains(@ne, 'Nr')">
				<font color="purple"><xsl:value-of select="@cont"/></font>
			</xsl:when>
			<xsl:when test="contains(@ne, 'Nz')">
				<font color="brown"><xsl:value-of select="@cont"/></font>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@cont"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
	</xsl:for-each>
</xsl:template>


<!--��������-->
<xsl:template match="sent" mode="wsd">
	<xsl:for-each select="word">
		<xsl:variable name="wsdexp" select="@wsdexp"/>
		<xsl:value-of select="@cont"/>/<font title="{$wsdexp}" color="blue"><xsl:value-of select="@wsd"/></font>
		<xsl:text>��</xsl:text>
	</xsl:for-each>
</xsl:template>


<!--�䷨����-->
<xsl:template match="sent" mode="parser">
	<p>
	<xsl:variable name="pid" select="../@id"/>
	<xsl:variable name="sid" select="@id" />
	<input type="button" name="button" value="��" onclick="display_parser('{$pid}', '{$sid}')"
	style="background-color:white; border-style:none; color:blue"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="@cont"/>
	<div id="{$pid}_{$sid}_parser" style="display:none;position:relative">
	</div>
	</p>
</xsl:template>


<!--�������-->
<xsl:template match="sent" mode="srl">
	<p>
	<xsl:variable name="pid" select="../@id"/>
	<xsl:variable name="sid" select="@id" />
	<input type="button" name="button" value="��" onclick="display_srl('{$pid}', '{$sid}')"
	style="background-color:white; border-style:none; color:blue"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="@cont"/>
	<div id="{$pid}_{$sid}_srl" style="display:none">
	</div>
	</p>
</xsl:template>

<!--��������ʾ-->
<xsl:template match="sent" mode="all">
	<p>
	<xsl:variable name="pid" select="../@id"/>
	<xsl:variable name="sid" select="@id" />
	<input type="button" name="button" value="��" onclick="display_all('{$pid}', '{$sid}')"
	style="background-color:white; border-style:none; color:blue"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="@cont"/>
	<div id="{$pid}_{$sid}_all" style="display:none;position:relative">
	</div>
	</p>
</xsl:template>

</xsl:stylesheet>
