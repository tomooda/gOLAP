Class {
	#name : 'GolapFilterParserTest',
	#superclass : 'TestCase',
	#instVars : [
		'parser'
	],
	#category : 'Golap-UI-Tests',
	#package : 'Golap-UI',
	#tag : 'Tests'
}

{ #category : 'running' }
GolapFilterParserTest >> setUp [

	parser := GolapFilterParser new
]

{ #category : 'tests' }
GolapFilterParserTest >> testConjunctiveFilter [

	self
		assert: (parser conjunctiveFilter end parse:
				 'and(isin(abc, 1, 2, 3), isin(xyz, 4, 5, 6))')
		equals: {
				('abc' -> 'isin(abc, 1, 2, 3)').
				('xyz' -> 'isin(xyz, 4, 5, 6)') } asHiDeSyntaxDictionary.
	self assert: (parser conjunctiveFilter end parse:
			 'and(isin(abc, 1, 2, 3), isin(abc, 4, 5, 6))') isPetit2Failure
]

{ #category : 'tests' }
GolapFilterParserTest >> testField [

	self assert: (parser field end parse: 'abc') equals: 'abc'.
	self assert: (parser field end parse: 'abc1') equals: 'abc1'.
	self assert: (parser field end parse: 'あいう') equals: 'あいう'.
	self assert: (parser field end parse: '.') isPetit2Failure.
	self assert: (parser field end parse: ',') isPetit2Failure.
	self assert: (parser field end parse: '(') isPetit2Failure.
	self assert: (parser field end parse: ')') isPetit2Failure.
	self assert: (parser field end parse: '-') isPetit2Failure.
	self assert: (parser field end parse: '0') isPetit2Failure.
	self assert: (parser field end parse: ' abc') isPetit2Failure.
	self assert: (parser field end parse: 'abc ') isPetit2Failure
]

{ #category : 'tests' }
GolapFilterParserTest >> testFieldFilter [

	self
		assert: (parser fieldFilter end parse:
				 'or(isin(abc, 0), and(isin(abc, 1, 2, 3), not(isin(xyz, 4, 5))))')
		equals: 'abc'
			->
			'or(isin(abc, 0), and(isin(abc, 1, 2, 3), not(isin(xyz, 4, 5))))'.
	self
		assert: (parser fieldFilter end parse: 'isin(abc, 1, 2, 3)')
		equals: 'abc' -> 'isin(abc, 1, 2, 3)'
]

{ #category : 'tests' }
GolapFilterParserTest >> testFilter [

	self
		assert: (parser filter end parse:
				 'and(isin(abc, 1, 2, 3), isin(xyz, 4, 5, 6))')
		equals: {
				('abc' -> 'isin(abc, 1, 2, 3)').
				('xyz' -> 'isin(xyz, 4, 5, 6)') } asHiDeSyntaxDictionary.
	self
		assert: (parser filter end parse: 'isin(abc, 1, 2, 3)')
		equals: { ('abc' -> 'isin(abc, 1, 2, 3)') } asHiDeSyntaxDictionary.
	self
		assert: (parser filter end parse: ' any other predicates ')
		equals: ' any other predicates '
]

{ #category : 'tests' }
GolapFilterParserTest >> testGuardedIsin [

	self
		assert: (parser guardedIsin end parse:
				 ' and(isin(abc, 1, 2, 3), not(isin(xyz, 4, 5))) ')
		equals: 'abc' -> ' and(isin(abc, 1, 2, 3), not(isin(xyz, 4, 5))) '
]

{ #category : 'tests' }
GolapFilterParserTest >> testIsin [

	self
		assert: (parser isin end parse: 'isin(abc,1,2,3)')
		equals: 'abc' -> 'isin(abc,1,2,3)'.
	self
		assert: (parser isin end parse: ' isin ( abc , 1 , 2 , 3 ) ')
		equals: 'abc' -> ' isin ( abc , 1 , 2 , 3 ) '
]

{ #category : 'tests' }
GolapFilterParserTest >> testMultiChoiceFieldFilter [

	self
		assert: (parser multiChoiceFieldFilter end parse:
				 'or(isin(abc, 0), and(isin(abc, 1, 2, 3), not(isin(xyz, 4, 5))))')
		equals: 'abc'
			->
			'or(isin(abc, 0), and(isin(abc, 1, 2, 3), not(isin(xyz, 4, 5))))'.
	self assert: (parser multiChoiceFieldFilter end parse:
			 'or(isin(abc, 0), and(isin(abc0, 1, 2, 3), not(isin(xyz, 4, 5))))')
			isPetit2Failure
]

{ #category : 'tests' }
GolapFilterParserTest >> testNumber [

	self assert: (parser number end parse: '0') equals: '0'.
	self assert: (parser number end parse: '123') equals: '123'.
	self assert: (parser number end parse: '-123') equals: '-123'.
	self assert: (parser number end parse: '3.14') equals: '3.14'.
	self assert: (parser number end parse: '-3.14') equals: '-3.14'.
	self assert: (parser number end parse: ' 0') isPetit2Failure.
	self assert: (parser number end parse: '0 ') isPetit2Failure.
	self assert: (parser number end parse: '- 123') isPetit2Failure
]

{ #category : 'tests' }
GolapFilterParserTest >> testString [

	self assert: (parser string end parse: '''abc''') equals: '''abc'''.
	self assert: (parser string end parse: '''あいう''') equals: '''あいう'''.
	self
		assert: (parser string end parse: '''ab\''c''')
		equals: '''ab\''c'''.
	self
		assert: (parser string end parse: ''' abc ''')
		equals: ''' abc '''.
	self assert: (parser string end parse: ' ''abc''') isPetit2Failure.
	self assert: (parser string end parse: '''abc'' ') isPetit2Failure
]
