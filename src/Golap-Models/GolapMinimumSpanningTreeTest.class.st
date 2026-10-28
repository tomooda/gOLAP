Class {
	#name : 'GolapMinimumSpanningTreeTest',
	#superclass : 'TestCase',
	#category : 'Golap-Models-Tests',
	#package : 'Golap-Models',
	#tag : 'Tests'
}

{ #category : 'testdata' }
GolapMinimumSpanningTreeTest >> dataDo: aBlock [

	aBlock
		value: {
				{ 'node1'. 'node2'. 2 }.
				{ 'node2'. 'node3'. 3 }.
				{ 'node3'. 'node4'. 4 }.
				{ 'node1'. 'node5'. 3 }.
				{ 'node2'. 'node5'. 2.5 }.
				{ 'node2'. 'node6'. 2.6 }.
				{ 'node3'. 'node7'. 2.7 }.
				{ 'node4'. 'node7'. 2.8 }.
				{ 'node4'. 'node8'. 2.9 }.
				{ 'node5'. 'node6'. 3 }.
				{ 'node6'. 'node7'. 1 }.
				{ 'node7'. 'node8'. 3 } }
		value: {
				{ 'node1'. 'node2'. 2 }.
				{ 'node2'. 'node5'. 2.5 }.
				{ 'node2'. 'node6'. 2.6 }.
				{ 'node3'. 'node7'. 2.7 }.
				{ 'node4'. 'node7'. 2.8 }.
				{ 'node4'. 'node8'. 2.9 }.
				{ 'node6'. 'node7'. 1 } }.

	aBlock
		value: {
				{ 'x'. 'a'. 6 }.
				{ 'x'. 'b'. 1 }.
				{ 'a'. 'c'. 3 }.
				{ 'b'. 'c'. 5 }.
				{ 'b'. 'd'. 4 }.
				{ 'd'. 'e'. 2 }.
				{ 'c'. 'y'. 2 }.
				{ 'e'. 'y'. 3 } }
		value: {
				{ 'a'. 'c'. 3 }.
				{ 'b'. 'd'. 4 }.
				{ 'c'. 'y'. 2 }.
				{ 'd'. 'e'. 2 }.
				{ 'e'. 'y'. 3 }.
				{ 'x'. 'b'. 1 } }.
	aBlock
		value: {
				{ 'A'. 'B'. 1 }.
				{ 'B'. 'C'. 4 }.
				{ 'C'. 'A'. 4 }.
				{ 'C'. 'D'. 2 } }
		value: {
				{ 'A'. 'B'. 1 }.
				{ 'B'. 'C'. 4 }.
				{ 'C'. 'D'. 2 } }.
	aBlock
		value: {
				{ 'A'. 'B'. 1 }.
				{ 'B'. 'C'. 1 }.
				{ 'C'. 'D'. 2 }.
				{ 'X'. 'Y'. 3 }.
				{ 'X'. 'Z'. 2 }.
				{ 'Y'. 'Z'. 2 } }
		value: {
				{ 'A'. 'B'. 1 }.
				{ 'B'. 'C'. 1 }.
				{ 'C'. 'D'. 2 }.
				{ 'X'. 'Z'. 2 }.
				{ 'Y'. 'Z'. 2 } }
]

{ #category : 'testing' }
GolapMinimumSpanningTreeTest >> testMinimumSpanningTreeFrom [

	self dataDo: [ :edges :treeEdges |
			| solver result |
			solver := GolapMinimumSpanningTree new.
			result := solver minimumSpanningTreeFrom: edges.
			self assert: result asSet equals: treeEdges asSet ]
]
