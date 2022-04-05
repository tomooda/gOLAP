Class {
	#name : #GolapTransactionFilterSpec,
	#superclass : #GolapFilterSpec,
	#category : #'Golap-Query'
}

{ #category : #examples }
GolapTransactionFilterSpec class >> exampleQuery [
	<script: 'GolapTransactionFilterSpec exampleQuery inspect'>
	^ self
		withAll:
			{(GolapQueryItemClauseSpec fromString: 'name:*beer*' ifError: [ nil ]).
			(GolapQueryItemClauseSpec
				fromString: 'category*liquor*'
				ifError: [ nil ]).
			(GolapQueryTransactionClauseSpec
				fromString: 'date:20191201...20121231'
				ifError: [ nil ])}
]

{ #category : #enumerating }
GolapTransactionFilterSpec >> itemClausesDo: aBlock [
	clauses do: [ :clause | clause itemClausesDo: aBlock ]
]

{ #category : #printing }
GolapTransactionFilterSpec >> printQueryOn: aStream [
	| itemClauses transactionClauses |
	itemClauses := Array
		streamContents: [ :stream | 
			self
				itemClausesDo: [ :clause | 
					clause hasPredicates
						ifTrue: [ stream nextPut: clause ] ] ].
	transactionClauses := Array
		streamContents: [ :stream | 
			self
				transactionClausesDo: [ :clause | 
					(clause hasPredicates or: [ clause hasItemFilter ])
						ifTrue: [ stream nextPut: clause ] ] ].
	(itemClauses size min: 1) + transactionClauses size >= 2
		ifTrue: [ aStream nextPutAll: 'and(' ].
	transactionClauses
		do: [ :clause | clause printQueryOn: aStream ]
		separatedBy: [ aStream nextPut: $, ].
	(transactionClauses notEmpty and: [ itemClauses notEmpty ])
		ifTrue: [ aStream nextPut: $, ].
	itemClauses
		ifNotEmpty: [ aStream nextPutAll: 'sel_item('.
			itemClauses size >= 2
				ifTrue: [ aStream nextPutAll: 'and(' ].
			itemClauses
				do: [ :clause | clause printQueryOn: aStream ]
				separatedBy: [ aStream nextPut: $, ].
			itemClauses size >= 2
				ifTrue: [ aStream nextPut: $) ].
			aStream nextPut: $) ].
	(itemClauses size min: 1) + transactionClauses size >= 2
		ifTrue: [ aStream nextPut: $) ]
]

{ #category : #enumerating }
GolapTransactionFilterSpec >> transactionClausesDo: aBlock [
	clauses do: [ :clause | clause transactionClausesDo: aBlock ]
]
