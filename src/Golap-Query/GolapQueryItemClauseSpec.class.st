Class {
	#name : #GolapQueryItemClauseSpec,
	#superclass : #GolapQueryClauseSpec,
	#category : #'Golap-Query'
}

{ #category : #examples }
GolapQueryItemClauseSpec class >> exampleNameField [
	<script: 'GolapQueryClauseSpec exampleNameField inspect'>
	^ GolapQueryItemClauseSpec fromString: 'name : John, Jack*, Jen...Jezzz, Johnson'
]

{ #category : #testing }
GolapQueryItemClauseSpec >> isItemClause [
	^ true
]

{ #category : #enumerating }
GolapQueryItemClauseSpec >> itemClausesDo: aBlock [
	aBlock value: self
]
