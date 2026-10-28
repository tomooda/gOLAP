Class {
	#name : 'GolapStoerWagnerCutterTest',
	#superclass : 'TestCase',
	#category : 'Golap-Models-Tests',
	#package : 'Golap-Models',
	#tag : 'Tests'
}

{ #category : 'testdata' }
GolapStoerWagnerCutterTest >> dataDo: aBlock [

	aBlock
		value: {
				{ 'node1'. 'node2'. 2 }.
				{ 'node2'. 'node3'. 3 }.
				{ 'node3'. 'node4'. 4 }.
				{ 'node1'. 'node5'. 3 }.
				{ 'node2'. 'node5'. 2 }.
				{ 'node2'. 'node6'. 2 }.
				{ 'node3'. 'node7'. 2 }.
				{ 'node4'. 'node7'. 2 }.
				{ 'node4'. 'node8'. 2 }.
				{ 'node5'. 'node6'. 3 }.
				{ 'node6'. 'node7'. 1 }.
				{ 'node7'. 'node8'. 3 } }
		value: {
				{ 'node1'. 'node2'. 'node5'. 'node6' }.
				{ 'node3'. 'node4'. 'node7'. 'node8' } }
		value: {
				{ 'node2'. 'node3'. 3 }.
				{ 'node6'. 'node7'. 1 } }.

	aBlock
		value: {
				{ 'x'. 'a'. 4 }.
				{ 'x'. 'b'. 1 }.
				{ 'a'. 'c'. 3 }.
				{ 'b'. 'c'. 5 }.
				{ 'b'. 'd'. 4 }.
				{ 'd'. 'e'. 2 }.
				{ 'c'. 'y'. 2 }.
				{ 'e'. 'y'. 3 } }
		value: {
				{ 'e'. 'y' }.
				{ 'c'. 'a'. 'd'. 'x'. 'b' } }
		value: {
				{ 'd'. 'e'. 2 }.
				{ 'c'. 'y'. 2 } }.
	aBlock
		value: {
				{ 'A'. 'B'. 1 }.
				{ 'B'. 'C'. 4 }.
				{ 'C'. 'A'. 4 }.
				{ 'C'. 'D'. 2 } }
		value: {
				{ 'A'. 'B'. 'C' }.
				{ 'D' } }
		value: { { 'C'. 'D'. 2 } }.
	aBlock
		value: {
				{ 'A'. 'B'. 1 }.
				{ 'B'. 'C'. 1 }.
				{ 'C'. 'D'. 2 }.
				{ 'X'. 'Y'. 3 }.
				{ 'X'. 'Z'. 2 }.
				{ 'Y'. 'Z'. 2 } }
		value: {
				{ 'A'. 'B'. 'C'. 'D' }.
				{ 'X'. 'Y'. 'Z' } }
		value: {  }
]

{ #category : 'tests' }
GolapStoerWagnerCutterTest >> testBestClusterByGlobalMinimumCut [

	self dataDo: [ :edges :clusters :cutEdges |
			| solver result |
			solver := GolapStoerWagnerCutter new.
			result := (solver bestClusterByGlobalMinimumCut: edges) sorted.
			self assert: (clusters includes: result) ]
]

{ #category : 'tests' }
GolapStoerWagnerCutterTest >> testGlobalMinimumCut [

	| solver result |
	self dataDo: [ :edges :clusters :cutEdges |
			solver := GolapStoerWagnerCutter new.
			result := solver globalMinimumCut: edges.
			self assert: result equals: cutEdges ]
]
