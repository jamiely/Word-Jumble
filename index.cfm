<cfset application.wordjumble = CreateObject("component", "model.WordJumble").init() />
<cfset application.wordjumble.setCache(application.wordcache) />
<cffunction name="getMaskCombinations">
	<cfargument name="word" />
	<cfset var local = StructNew() />
	<cfset local.masks = ArrayNew(1) />
	<cfloop from="1" to="#Len(arguments.word)#" index="i">
		<cfset chr = application.wordjumble.getCharAt(arguments.word, i) />
		<cfset arrayAppend(local.masks, application.wordjumble.replaceCharAt(arguments.word, i, "[^#chr#]")) />
	</cfloop>
	
	<cfreturn local.masks />
</cffunction>

<cffunction name="build">
	<cfargument name="initialWord" />
	<cfargument name="chainLength" default="5" />
	<cfargument name="prohibitWords" default="" />
	
	<cfset var local = StructNew() />
	<cfset local.words = "" />
	<cfset arguments.prohibitWords = ListAppend(arguments.prohibitWords, arguments.initialWord) />
	
	<cfloop array="#getMaskCombinations(arguments.initialWord)#" index="local.mask">
		

		<cfif arguments.chainLength EQ 1>
			<cfset local.words = arguments.initialWord />
		<cfelse>
			<cfset local.mask = application.wordjumble.makeMaskSimple(arguments.initialWord) />

			<cfset local.options = application.wordjumble.getWords(local.mask, 1) />
		
			<cfloop array="#local.options#" index="local.w">
				<cfif ListContains(arguments.prohibitWords, local.w) EQ 0>
					<cfset local.result = build(local.w, chainLength-1, arguments.prohibitWords) />
					<cfif listlen(local.result) GTE ListLen(local.words)>
						<cfset local.words = ListAppend(local.result, arguments.initialWord) />
					
						<cfif ListLen(local.words) GTE chainLength>
							<cfbreak />
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<cfif ListLen(local.words) GTE chainLength>
			<cfbreak />
		</cfif>
	</cfloop>	
	
	<cfreturn local.words />
</cffunction>
<cfset word = application.wordjumble.getRandomWord() />
<cfset chain = "" />

<cfset chainLength = 5 />
<cfif StructKeyExists(url, "length")>
	<cfset chainLength = url.length />
</cfif>
<cfif StructKeyExists(url, "word")>
	<cfset word = url.word />
</cfif>
<cfset chain = build(word, chainLength) />



<html>
<head>

	<link rel="stylesheet" href="assets/css/screen.css" type="text/css" media="screen, projection" />
	<link rel="stylesheet" href="assets/css/print.css" type="text/css" media="print" />
	<!--[if IE]>
		<link rel="stylesheet" href="asses/css/ie.css" type="text/css" media="screen, projection" />
	<![endif]-->
	<link rel="stylesheet" href="assets/css/style.css" type="text/css" media="screen, projection" />
	
	<style type="text/css" media="screen">
		#game div.word { padding-left:14px; color:#666;}
		#game li {line-height: 60px;}
		#game li, #game input[type=text] {border:0px; font-family: verdana, sans-serif; font-size: xx-large;}
		#game input[type=text] {
			border-bottom:2px #EEE solid;
			margin-bottom: 2px;
			width: 150px;
		}
		#game input[type=text].correct {
			border-bottom:2px #04B404 solid;
		}
		#game input[type=text].incorrect {
			border-bottom:2px #FE2E2E solid;
		}
		input[type=button] {
			font-size: large;
			margin-right: 10px;
		}
	</style>
	<script type="text/javascript" charset="utf-8" src="assets/javascript/jquery/jquery-1.3.2.min.js"></script>
	<script type="text/javascript" charset="utf-8">
		$(document).ready(function(){
			var words = ["<cfoutput>#Replace(chain, ',', '","', 'all')#</cfoutput>"],
				html = [];
				
			if (words.length == 1) {
				alert('Could not generate words. Refresh!');
				return;
			}
			
			jQuery.each (words, function(i, v){
				inner = i == 0 || i == words.length - 1 ? '<div class="word">'+v+'</div>' :
					'<input maxlength='+v.length+' class="answer" type="text" answer="'+v+'">'
				html.push ('<li>'+inner+'</li>');
			});
			$('#game').html(
				'<ul>' + html.join('\n') + '</ul>' +
				//'<input type="button" value="Check" id="btnCheck" />' +
				'<input type="button" value="Hint" id="btnHint" />' +
				'<input type="button" value="I Quit!" id="btnQuit" />'
			);
			
			$('#game .answer').keyup(function(){
				var t = $(this);
				t.removeClass('incorrect');
				t.removeClass('correct');
				
				var v = t.val(),
					answer = t.attr('answer');
				
				if (v.length != answer.length ) return;
				
				if (new RegExp(answer, 'i').test(v)) {
					t.addClass('correct');	
				} 
				else {
					t.addClass('incorrect');
				}
			});
			
			
			$('#btnCheck').click(function(){
				$('#game .answer').each(function(){
					var t = $(this);
					if (new RegExp(t.attr('answer'), 'i').test(t.val())) {
						t.addClass('correct');
						t.removeClass('incorrect');
					} 
					else {
						t.addClass('incorrect');
						t.removeClass('correct');
					}
				});
			});
			
			$('#btnQuit').click(function(){
				$('#game .answer').each(function(){
					var t = $(this);
					t.val(t.attr('answer'));
				});
				$('#btnCheck').click();
			});
			
			$('#btnHint').click(function(){
				var first = true;
				$('#game .answer').each(function(){
					var t = $(this);
					if (first && ! new RegExp(t.attr('answer'), 'i').test(t.val())) {
						// is not the correct answer
						t.val(t.attr('answer'));
						first = false;
						t.addClass('correct');	
					} 
				});
			});
			
			
			
		});
	</script>
</head>
<cfoutput>
<body>
<div class="container">
	<div id="content">
		<h1>LL Word Jumble</h1>
		
		<div id="game">
			
		</div>
		<a href="wordjumble.zip">Source</a>
		
		

		<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />

		<h1>Generate Puzzle</h1>
		<div>
			<ul>
				<li><form><input type="text" name="startingWord" /><input type="submit" value="Generate"></form></li>
			</ul>
			
			Random Word: #word#<br>
			<cfset mask =application.wordjumble.makeMaskSimple(word, 1) />
			Make mask: #mask#



			<h2>Possible Matches</h2>
			
			<ul>
				<cfloop list="#chain#" index="word">
				<li>#word#</li>
				</cfloop>
			</ul>
		</div>
	</div>
	
</div>
</cfoutput>
</body>
</html>
