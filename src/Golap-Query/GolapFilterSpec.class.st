Class {
	#name : 'GolapFilterSpec',
	#superclass : 'GolapAbstractQuerySpec',
	#instVars : [
		'clauses'
	],
	#category : 'Golap-Query-AST',
	#package : 'Golap-Query',
	#tag : 'AST'
}

{ #category : 'instance creation' }
GolapFilterSpec class >> fromJSON: aJSONObject [
	^ self
		withAll: (aJSONObject collect: [ :obj | GolapQueryClauseSpec fromJSON: obj ])
]

{ #category : 'instance creation' }
GolapFilterSpec class >> fromString: aString ifError: errorBlock [
	| query |
	query := self new.
	(aString substrings: '&')
		do: [ :line | 
			line trim
				ifNotEmpty: [ :clauseString | 
					query
						addClause:
							(GolapQueryClauseSpec
								fromString: clauseString
								ifError: [ :msg | ^ errorBlock cull: msg ]) ] ].
	^ query
]

{ #category : 'testing' }
GolapFilterSpec class >> isAbstract [

	^ self = GolapFilterSpec
]

{ #category : 'instance creation' }
GolapFilterSpec class >> withAll: aCollectionOfGolapQueryClauseSpec [
	| query |
	query := self new.
	aCollectionOfGolapQueryClauseSpec
		do: [ :clause | query addClause: clause ].
	^ query
]

{ #category : 'comparing' }
GolapFilterSpec >> = anObject [
	^ self class = anObject class and: [ clauses = anObject clauses ]
]

{ #category : 'adding' }
GolapFilterSpec >> addClause: aGolapQueryClauseSpec [
	^ clauses add: aGolapQueryClauseSpec
]

{ #category : 'converting' }
GolapFilterSpec >> asJSON [
	^ clauses collect: #asJSON
]

{ #category : 'accessing' }
GolapFilterSpec >> clauses [
	^ clauses
]

{ #category : 'accessing' }
GolapFilterSpec >> clauses: aCollectionOfGolapQueryClauseSpec [
	clauses := aCollectionOfGolapQueryClauseSpec asOrderedCollection
]

{ #category : 'operations' }
GolapFilterSpec >> clearWarningsAndErrors [
	clauses do: [ :clause | clause clearWarningsAndErrors ]
]

{ #category : 'enumerating' }
GolapFilterSpec >> guardedPredicatesDo: aBlock [
	clauses do: [ :clause | clause guardedPredicatesDo: aBlock ]
]

{ #category : 'testing' }
GolapFilterSpec >> hasPredicates [
	^ clauses anySatisfy: #hasPredicates
]

{ #category : 'comparing' }
GolapFilterSpec >> hash [
	^ self class hash bitXor: clauses hash
]

{ #category : 'initialization' }
GolapFilterSpec >> initialize [ 
	super initialize.
	clauses := OrderedCollection new
]

{ #category : 'testing' }
GolapFilterSpec >> isFilterSpec [
	^ true
]

{ #category : 'printing' }
GolapFilterSpec >> printQueryFromClauses: aCollectionOfGolapQueryClauseSpec on: aStream [

	| conjuncts disjuncts |
	conjuncts := OrderedCollection new.
	disjuncts := OrderedCollection new.
	aCollectionOfGolapQueryClauseSpec do: [ :clause |
			clause isDisjunct
				ifTrue: [ disjuncts add: clause query ]
				ifFalse: [ conjuncts add: clause query ] ].
	disjuncts size = 1 ifTrue: [ conjuncts add: disjuncts first ].
	disjuncts size > 1 ifTrue: [
			conjuncts add: (String streamContents: [ :stream |
						 stream nextPutAll: 'or('.
						 disjuncts
							 do: [ :disjunct | stream nextPutAll: disjunct ]
							 separatedBy: [ stream nextPut: $, ].
						 stream nextPut: $) ]) ].
	conjuncts size = 1 ifTrue: [ aStream nextPutAll: conjuncts first ].
	conjuncts size > 1 ifTrue: [
			aStream nextPutAll: 'and('.
			conjuncts
				do: [ :conjunct | aStream nextPutAll: conjunct ]
				separatedBy: [ aStream nextPut: $, ].
			aStream nextPut: $) ]
]

{ #category : 'printing' }
GolapFilterSpec >> printSpecOn: aStream [
	clauses
		do: [ :clause | clause printSpecOn: aStream ]
		separatedBy: [ aStream nextPutAll: ' & ' ]
]

{ #category : 'adding' }
GolapFilterSpec >> removeClause: aGolapQueryClauseSpec ifAbsent: errorBlock [
	^ clauses remove: aGolapQueryClauseSpec ifAbsent: errorBlock
]
