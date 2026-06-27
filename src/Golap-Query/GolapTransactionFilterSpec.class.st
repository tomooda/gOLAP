Class {
	#name : 'GolapTransactionFilterSpec',
	#superclass : 'GolapFilterSpec',
	#category : 'Golap-Query-AST',
	#package : 'Golap-Query',
	#tag : 'AST'
}

{ #category : 'examples' }
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

{ #category : 'enumerating' }
GolapTransactionFilterSpec >> itemClausesDo: aBlock [
	clauses do: [ :clause | clause itemClausesDo: aBlock ]
]

{ #category : 'printing' }
GolapTransactionFilterSpec >> printQueryOn: aStream [

	| itemClauses transactionClauses |
	itemClauses := Array streamContents: [ :stream |
			               self itemClausesDo: [ :clause |
				               clause hasPredicates ifTrue: [
					               stream nextPut: clause ] ] ].
	transactionClauses := Array streamContents: [ :stream |
			                      self transactionClausesDo: [ :clause |
					                      (clause hasPredicates or: [
						                       clause hasItemFilter ]) ifTrue: [
						                      stream nextPut: clause ] ] ].
	(itemClauses notEmpty and: [ transactionClauses notEmpty ]) ifTrue: [
		aStream nextPutAll: 'and(' ].
	transactionClauses ifNotEmpty: [
			self printQueryFromClauses: transactionClauses on: aStream.
			itemClauses ifNotEmpty: [ aStream nextPut: $, ] ].
	itemClauses ifNotEmpty: [
			aStream nextPutAll: 'sel_item('.
			self printQueryFromClauses: itemClauses on: aStream.
			aStream nextPut: $) ].
	(itemClauses notEmpty and: [ transactionClauses notEmpty ]) ifTrue: [
		aStream nextPut: $) ]
]

{ #category : 'enumerating' }
GolapTransactionFilterSpec >> transactionClausesDo: aBlock [
	clauses do: [ :clause | clause transactionClausesDo: aBlock ]
]
