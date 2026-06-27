Class {
	#name : 'GolapItemFilterSpec',
	#superclass : 'GolapFilterSpec',
	#category : 'Golap-Query-AST',
	#package : 'Golap-Query',
	#tag : 'AST'
}

{ #category : 'examples' }
GolapItemFilterSpec class >> exampleQuery [
	<script: 'GolapItemFilterSpec exampleQuery inspect'>
	^ self fromString: '
A : a1, b*, ca ... cz, a2 & B : x, y, z'
]

{ #category : 'printing' }
GolapItemFilterSpec >> printQueryOn: aStream [

	| effectiveClauses |
	effectiveClauses := clauses select: #hasPredicates.
	self printQueryFromClauses: effectiveClauses on: aStream
]
