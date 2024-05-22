Class {
	#name : 'GolapNodeTest',
	#superclass : 'TestCase',
	#instVars : [
		'node1',
		'node2',
		'node3'
	],
	#category : 'Golap-Models-Tests',
	#package : 'Golap-Models',
	#tag : 'Tests'
}

{ #category : 'running' }
GolapNodeTest >> setUp [

	node1 := GolapNode
		           on:
		           (DataSeries withKeys: { 'value' } values: { 10 } name: 1)
		           name: 'v1'.
	node2 := GolapNode
		           on:
		           (DataSeries withKeys: { 'value' } values: { 20 } name: 2)
		           name: 'v2'.
	node3 := GolapNode
		           on:
		           (DataSeries withKeys: { 'value' } values: { 30 } name: 3)
		           name: 'v3'
]

{ #category : 'tests' }
GolapNodeTest >> testCopy [

	| copy |
	copy := node1 copy.
	self deny: copy identicalTo: node1.
	self assert: copy id equals: node1 id.
	self assert: copy name equals: node1 name.
	self assert: (copy at: 'value') equals: (node1 at: 'value').
	node1 data at: 'value' put: 0.
	self assert: (copy at: 'value') equals: 10
]

{ #category : 'tests' }
GolapNodeTest >> testDiff [

	self assert: (node1 at: 'value') equals: 10.
	self assert: (node2 at: 'value') equals: 20.
	node1 diff: node2.
	self assert: (node1 at: 'value') equals: -10.
	self assert: (node2 at: 'value') equals: 20
]
