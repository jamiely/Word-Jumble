<cfcomponent>
	<cffunction name="init">
		<cfset this.wordLength = 5 />
		<cfset this.dictionaryCachePath = ExpandPath(".")&"/dictionary-cache.txt" />
		<cfset this.cache = "" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="range">
		<cfargument name="min" />
		<cfargument name="max" />	
		<cfset var rtn = ArrayNew(1) />	
		<cfloop from="#min#" to="#max#" index="i">
			<cfset ArrayAppend(rtn, i) />
		</cfloop>
		<cfreturn rtn />
	</cffunction>
	
	<cffunction name="setCache">
		<cfargument name="words" type="Array" required="true" />
		<cfset this.cache = arguments.words />
		
	</cffunction>
	
	<cffunction name="getWordCache">
		<cfset var local = structnew() />
		<cfset local.words = arrayNew(1) />
		<cfset local.dictionary = FileOpen(this.dictionaryCachePath, "read") />
		<cfloop condition="NOT FileIsEOF(local.dictionary)">
			<cfset local.line = FileReadLine(local.dictionary) />
			<cfset ArrayAppend(local.words, local.line) />
		</cfloop>
		<cfreturn local.words />
	</cffunction>
	
	<cffunction name="getRandomWord">
		<cfreturn this.cache[RandRange(1, ArrayLen(this.cache))] />
	</cffunction>
	
	<cffunction name="makeMaskSimple">
		<cfargument name="word" />
		<cfargument name="numberOfCharsToMask" required="false" default="0" />
		
		<cfset var local = StructNew() />
		<cfset local.pos = RandRange(1, this.wordLength) />
		<cfset local.chr = Mid(arguments.word,local.pos,1) />
		<cfset local.word = arguments.word />
		
		<cfset local.rightLen = this.wordLength - local.pos />			
		<cfset local.right = "" />
		<cfif local.rightLen NEQ 0>
			<cfset local.right = right(local.word, this.wordLength - local.pos) />
		</cfif>
		<cfset local.leftLen = local.pos - 1 />
		<cfset local.left = "" />
		<cfif local.leftLen NEQ 0>
			<cfset local.left = left(local.word, local.leftLen ) />
		</cfif>
	
		<cfset local.word = local.left & "[^"&local.chr&"]" & local.right />
		
		<cfreturn local.word  />
	</cffunction>
	
	<cffunction name="getCharAt">
		<cfargument name="orig" />
		<cfargument name="pos" />
		<cfreturn Mid(arguments.orig,arguments.pos,1) />
	</cffunction>
	
	<cffunction name="replaceCharAt">
		<cfargument name="orig" />
		<cfargument name="pos" />
		<cfargument name="replace" />
		<cfset var local = StructNew() />
		<cfset local.pos = arguments.pos />
		<cfset local.word = arguments.orig />
		
		<cfset local.rightLen = len(orig) - local.pos />			
		<cfset local.right = "" />
		<cfif local.rightLen NEQ 0>
			<cfset local.right = right(local.word, len(orig) - local.pos) />
		</cfif>
		<cfset local.leftLen = local.pos - 1 />
		<cfset local.left = "" />
		<cfif local.leftLen NEQ 0>
			<cfset local.left = left(local.word, local.leftLen ) />
		</cfif>
	
		<cfset local.word = local.left & arguments.replace & local.right />
		
		<cfreturn local.word  />

	</cffunction>
	
	<cffunction name="makeMask">
		<cfargument name="word" />
		<cfargument name="numberOfCharsToMask" required="false" default="0" />
		
		<cfset var local = StructNew() />
		<cfif arguments.numberOfCharsToMask EQ 0>
			<cfset arguments.numberOfCharsToMask = 1 />
		</cfif>	
		<cfset local.word = arguments.word />	
		<cfset local.mayBeMasked = this.range (1, this.wordLength) />

		<cfset local.counter = 0 />
		<cfloop condition="true">
			<cfset local.pos = RandRange(1, this.wordLength) />
			
			<cfif Mid(local.word, local.pos, 1) NEQ ".">
			
				<cfset local.rightLen = this.wordLength - local.pos />			
				<cfset local.right = "" />
				<cfif local.rightLen NEQ 0>
					<cfset local.right = right(local.word, this.wordLength - local.pos) />
				</cfif>
				<cfset local.leftLen = local.pos - 1 />
				<cfset local.left = "" />
				<cfif local.leftLen NEQ 0>
					<cfset local.left = left(local.word, local.leftLen ) />
				</cfif>
			
				<cfset local.word = local.left & "." & local.right />
				
				<cfset local.counter = local.counter + 1 />
				<cfif local.counter GTE arguments.numberOfCharsToMask>
					<cfbreak />
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn local.word />
	</cffunction>
	
	<cffunction name="getWords">
		<cfargument name="mask" />
		<cfset var local = structnew() />
		<cfset local.words = arraynew(1) />
		<cfset local.re ="\b" & mask & "\b" />
		<cfloop array="#this.cache#" index="i">
			<cfif REFindNoCase(local.re, i)>
				<cfset arrayappend(local.words, i) />
			</cfif>
		</cfloop>
		
		<cfreturn local.words />
	</cffunction>
	
	<cffunction name="buildChain">
		<cfargument name="initialWord" />
		<cfargument name="chainLength" default="5" />
		
		<cfset var local = StructNew() />
		<cfset local.words = "" />
		<cfset local.mask = this.makeMaskSimple(arguments.initialWord) />
		<cfdump var="#local.mask#" />
		<cfset local.options = this.getWords(local.mask, 1) />
		<cfdump var="#local.options#" />
		<cfif arguments.chainLength EQ 1>
			<cfset local.words = arguments.initialWord />
		<cfelse>
			<cfloop array="#local.options#" index="local.w">
				<cfset local.result = this.buildChain(local.w, chainLength-1) />
				<cfif listlen(local.result) GTE chainLength+1>
					<cfset local.words = ListAppend(local.result, arguments.initialWord) />
					<cfbreak  />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn local.words />
	</cffunction>
		
</cfcomponent>