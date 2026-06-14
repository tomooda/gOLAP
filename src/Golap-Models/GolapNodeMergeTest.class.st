Class {
	#name : 'GolapNodeMergeTest',
	#superclass : 'TestCase',
	#category : 'Golap-Models-Tests',
	#package : 'Golap-Models',
	#tag : 'Tests'
}

{ #category : 'tests-units' }
GolapNodeMergeTest >> testAsJSON [

	| merge |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	merge merge: #( 'a' '3' ) into: 'b'.
	merge merge: #( '1' '3' ) into: 'c'.
	self assert: merge asJSON equals: {
			('merges' -> {
				 ('a' -> #( '1' '2' )).
				 ('b' -> #( '3' 'a' )).
				 ('c' -> #( '1' '3' )) } asOrderedDictionary).
			('merges-roots' -> #( 'b' 'c' )) } asDictionary
]

{ #category : 'tests-units' }
GolapNodeMergeTest >> testFromJSON [

	| json merge |
	json := {
		        ('merges' -> {
			         ('a' -> #( '1' '2' )).
			         ('b' -> #( '3' 'a' )).
			         ('c' -> #( '1' '3' )) } asOrderedDictionary).
		        ('merges-roots' -> #( 'b' 'c' )) } asDictionary.
	merge := GolapNodeMerge new.
	merge fromJSON: json.
	self assert: merge asJSON equals: json
]

{ #category : 'tests-units' }
GolapNodeMergeTest >> testLeavesAtDo [

	| merge |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	merge merge: #( 'a' '3' ) into: 'b'.
	merge merge: #( '1' '3' ) into: 'c'.
	self
		assert: (Array streamContents: [ :stream |
				 merge leavesAt: 'a' do: [ :id | stream nextPut: id ] ]) sorted
		equals: #( '1' '2' ).
	self
		assert: (Array streamContents: [ :stream |
				 merge leavesAt: 'b' do: [ :id | stream nextPut: id ] ]) sorted
		equals: #( '1' '2' '3' ).
	self
		assert: (Array streamContents: [ :stream |
				 merge leavesAt: 'c' do: [ :id | stream nextPut: id ] ]) sorted
		equals: #( '1' '3' ).
	self
		assert: (Array streamContents: [ :stream |
				 merge leavesAt: '1' do: [ :id | stream nextPut: id ] ]) sorted
		equals: #( '1' ).
	self
		assert: (Array streamContents: [ :stream |
				 merge leavesAt: 'z' do: [ :id | stream nextPut: id ] ]) sorted
		equals: #( 'z' )
]

{ #category : 'tests-units' }
GolapNodeMergeTest >> testMergeInto [

	| merge |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	self assert: (merge leavesAt: 'a') sorted equals: #( '1' '2' ).
	merge merge: #( 'a' '3' ) into: 'b'.
	self assert: (merge leavesAt: 'a') sorted equals: #( '1' '2' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( '1' '2' '3' ).
	merge merge: #( '1' '3' ) into: 'c'.
	self assert: (merge leavesAt: 'a') sorted equals: #( '1' '2' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( '1' '2' '3' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( '1' '3' )
]

{ #category : 'tests-units' }
GolapNodeMergeTest >> testRootsAtDo [

	| merge roots |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	merge merge: #( 'a' '3' ) into: 'b'.
	merge merge: #( '1' '3' ) into: 'c'.
	roots := Set new.
	merge rootsAt: '1' do: [ :id | roots add: id ].
	self assert: roots sorted equals: #( 'b' 'c' ).
	roots := Set new.
	merge rootsAt: '4' do: [ :id | roots add: id ].

	self assert: roots sorted equals: #( '4' )
]

{ #category : 'tests-units' }
GolapNodeMergeTest >> testToJSON [

	| merge json |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	merge merge: #( 'a' '3' ) into: 'b'.
	merge merge: #( '1' '3' ) into: 'c'.
	json := Dictionary new.
	merge toJSON: json.
	self assert: json equals: {
			('merges' -> {
				 ('a' -> #( '1' '2' )).
				 ('b' -> #( '3' 'a' )).
				 ('c' -> #( '1' '3' )) } asOrderedDictionary).
			('merges-roots' -> #( 'b' 'c' )) } asDictionary
]

{ #category : 'tests-units' }
GolapNodeMergeTest >> testUnmerge [

	| merge |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	merge merge: #( 'a' '3' ) into: 'b'.
	merge merge: #( '1' '3' ) into: 'c'.
	merge unmerge: 'a'.
	self assert: (merge leavesAt: 'a') sorted equals: #( 'a' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( '1' '2' '3' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( '1' '3' ).
	merge unmerge: 'b'.
	self assert: (merge leavesAt: 'a') sorted equals: #( 'a' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( 'b' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( '1' '3' )
]

{ #category : 'tests-scenarios' }
GolapNodeMergeTest >> testUnmergeFIFOOrder [

	| merge |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	merge merge: #( 'a' '3' ) into: 'b'.
	merge merge: #( '1' '3' ) into: 'c'.
	merge unmerge: 'a'.
	self assert: (merge leavesAt: 'a') sorted equals: #( 'a' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( '1' '2' '3' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( '1' '3' ).
	merge unmerge: 'b'.
	self assert: (merge leavesAt: 'a') sorted equals: #( 'a' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( 'b' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( '1' '3' ).
	merge unmerge: 'c'.
	self assert: (merge leavesAt: 'a') sorted equals: #( 'a' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( 'b' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( 'c' )
]

{ #category : 'tests-scenarios' }
GolapNodeMergeTest >> testUnmergeLIFOOrder [

	| merge |
	merge := GolapNodeMerge new.
	merge merge: #( '1' '2' ) into: 'a'.
	merge merge: #( 'a' '3' ) into: 'b'.
	merge merge: #( '1' '3' ) into: 'c'.
	merge unmerge: 'c'.
	self assert: (merge leavesAt: 'a') sorted equals: #( '1' '2' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( '1' '2' '3' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( 'c' ).
	merge unmerge: 'b'.
	self assert: (merge leavesAt: 'a') sorted equals: #( '1' '2' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( 'b' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( 'c' ).
	merge unmerge: 'a'.
	self assert: (merge leavesAt: 'a') sorted equals: #( 'a' ).
	self assert: (merge leavesAt: 'b') sorted equals: #( 'b' ).
	self assert: (merge leavesAt: 'c') sorted equals: #( 'c' )
]
