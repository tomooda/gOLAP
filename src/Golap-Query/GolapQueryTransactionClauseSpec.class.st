Class {
	#name : #GolapQueryTransactionClauseSpec,
	#superclass : #GolapQueryClauseSpec,
	#instVars : [
		'itemFilter',
		'itemFilterQuantifier'
	],
	#category : #'Golap-Query'
}

{ #category : #'instance creation' }
GolapQueryTransactionClauseSpec class >> fromJSON: aJSONObject [
	^ (super fromJSON: aJSONObject)
		itemFilter:
			((aJSONObject at: 'itemFilter')
				ifNotNil: [ :obj | GolapItemFilterSpec fromJSON: obj ]);
		itemFilterQuantifier: (aJSONObject at: 'itemFilterQuantifier');
		yourself
]

{ #category : #converting }
GolapQueryTransactionClauseSpec >> asJSON [
	^ super asJSON
		at: 'itemFilter' put: (itemFilter ifNotNil: #asJSON);
		at: 'itemFilterQuantifier' put: itemFilterQuantifier;
		yourself
]

{ #category : #testing }
GolapQueryTransactionClauseSpec >> hasItemFilter [
	^ itemFilter notNil
		and: [ itemFilterQuantifier notNil and: [ itemFilter hasPredicates ] ]
]

{ #category : #testing }
GolapQueryTransactionClauseSpec >> isTransactionClause [
	^ true
]

{ #category : #accessing }
GolapQueryTransactionClauseSpec >> itemFilter [
	^ itemFilter
]

{ #category : #accessing }
GolapQueryTransactionClauseSpec >> itemFilter: aGolapItemFilterSpec [
	itemFilter := aGolapItemFilterSpec.
	itemFilter ifNil: [ itemFilterQuantifier := nil ]
]

{ #category : #accessing }
GolapQueryTransactionClauseSpec >> itemFilterFromFields: anArrayOfString quantifier: aBoolean [
	itemFilter := GolapItemFilterSpec
		withAll:
			(anArrayOfString
				collect: [ :itemField | GolapQueryItemClauseSpec on: itemField ]).
	itemFilterQuantifier := aBoolean = true
]

{ #category : #accessing }
GolapQueryTransactionClauseSpec >> itemFilterQuantifier [
	^ itemFilterQuantifier
]

{ #category : #accessing }
GolapQueryTransactionClauseSpec >> itemFilterQuantifier: aBoolean [
	itemFilterQuantifier := aBoolean
]

{ #category : #printing }
GolapQueryTransactionClauseSpec >> printQueryOn: aStream [
	| subqueries |
	(predicates isEmpty
		and: [ itemFilter isNil or: [ itemFilter hasPredicates not ] ])
		ifTrue: [ ^ self ].
	self isNegative
		ifTrue: [ aStream nextPutAll: 'not(' ].
	subqueries := Array
		streamContents: [ :queryStream | 
			(Array
				streamContents: [ :literals | 
					self
						bareLiteralsDo: [ :predicate | literals nextPut: predicate pattern golapQuoted ] ])
				ifNotEmpty: [ :bareLiterals | 
					queryStream
						nextPut:
							(String
								streamContents: [ :isinStream | 
									isinStream
										nextPutAll: 'isin(';
										nextPutAll: field.
									bareLiterals
										do: [ :literal | 
											isinStream
												nextPut: $,;
												nextPutAll: literal ].
									isinStream nextPut: $) ]) ].
			self
				guardedLiteralsDo: [ :predicate | queryStream nextPut: (predicate queryWith: field) ].
			self
				wildcardsDo: [ :predicate | queryStream nextPut: (predicate queryWith: field) ].
			self
				rangesDo: [ :predicate | queryStream nextPut: (predicate queryWith: field) ].
			(itemFilter notNil and: [ itemFilter hasPredicates ])
				ifTrue: [ queryStream
						nextPut:
							(String
								streamContents: [ :stream | 
									stream
										nextPutAll: 'having(';
										nextPutAll: field;
										nextPutAll: ',';
										nextPutAll:
											(self itemFilterQuantifier
												ifTrue: [ 'and' ]
												ifFalse: [ 'or' ]);
										nextPutAll: ','.
									itemFilter printQueryOn: stream.
									stream nextPut: $) ]) ] ].
	subqueries size >= 2
		ifTrue: [ aStream nextPutAll: 'or(' ].
	subqueries
		do: [ :subquery | aStream nextPutAll: subquery ]
		separatedBy: [ aStream nextPut: $, ].
	subqueries size >= 2
		ifTrue: [ aStream nextPut: $) ].
	self isNegative
		ifTrue: [ aStream nextPut: $) ]
]

{ #category : #printing }
GolapQueryTransactionClauseSpec >> printSpecOn: aStream [
	super printSpecOn: aStream.
	itemFilter
		ifNotNil: [ aStream nextPutAll: ',('.
			itemFilter printSpecOn: aStream.
			aStream nextPut: $) ]
]

{ #category : #accessing }
GolapQueryTransactionClauseSpec >> removeItemFilter [
	itemFilter := nil.
	itemFilterQuantifier := nil
]

{ #category : #enumerating }
GolapQueryTransactionClauseSpec >> transactionClausesDo: aBlock [
	aBlock value: self
]
