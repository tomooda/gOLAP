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
	effectiveClauses size >= 2
		ifTrue: [ aStream nextPutAll: 'and(' ].
	effectiveClauses
		do: [ :clause | clause printQueryOn: aStream ]
		separatedBy: [ aStream nextPut: $, ].
	effectiveClauses size >= 2
		ifTrue: [ aStream nextPut: $) ]
]
