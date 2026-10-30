Class {
	#name : 'GolapClipCollectionTest',
	#superclass : 'TestCase',
	#instVars : [
		'collection',
		'a',
		'b'
	],
	#category : 'Golap-Notepad-Tests',
	#package : 'Golap-Notepad',
	#tag : 'Tests'
}

{ #category : 'running' }
GolapClipCollectionTest >> setUp [

	collection := GolapClipCollection new.
	a := GolapClipForTest new
		     id: 'a';
		     yourself.
	b := GolapClipForTest new
		     id: 'b';
		     yourself
]

{ #category : 'testing' }
GolapClipCollectionTest >> testAdd [

	collection add: a.
	self assert: collection asArray equals: { a }.
	collection add: b.
	self assert: (collection sorted: #id ascending) equals: {
			a.
			b }.
	self should: [ collection add: a ] raise: GolapDuplicatedId.
	self
		should: [
				collection add: (GolapClipForTest new
						 id: 'a';
						 yourself) ]
		raise: GolapDuplicatedId
]

{ #category : 'testing' }
GolapClipCollectionTest >> testAt [

	collection
		add: a;
		add: b.
	self assert: (collection at: 'a') identicalTo: a.
	self assert: (collection at: 'b') identicalTo: b.
	self should: [ collection at: 'c' ] raise: KeyNotFound
]

{ #category : 'testing' }
GolapClipCollectionTest >> testAtIfAbsent [

	collection
		add: a;
		add: b.
	self assert: (collection at: 'a' ifAbsent: [ nil ]) identicalTo: a.
	self assert: (collection at: 'b' ifAbsent: [ nil ]) identicalTo: b.
	self assert: (collection at: 'c' ifAbsent: [ nil ]) equals: nil
]

{ #category : 'testing' }
GolapClipCollectionTest >> testAtIfPresent [

	collection
		add: a;
		add: b.
	self assert: (collection at: 'a' ifPresent: [ :clip | clip ]) identicalTo: a.
	self assert: (collection at: 'b' ifPresent: [ :clip | a ]) identicalTo: a.
	self assert: (collection at: 'c' ifPresent: [ :clip | clip ]) equals: nil
]

{ #category : 'testing' }
GolapClipCollectionTest >> testAtIfPresentIfAbsent [

	collection
		add: a;
		add: b.
	self assert: (collection at: 'a' ifPresent: [ :clip | clip ] ifAbsent: [ b ]) identicalTo: a.
	self assert: (collection at: 'b' ifPresent: [ :clip | a ] ifAbsent: [ b ]) identicalTo: a.
	self assert: (collection at: 'c' ifPresent: [ :clip | clip ] ifAbsent: [ a ]) identicalTo: a
]

{ #category : 'testing' }
GolapClipCollectionTest >> testRemove [

	collection add: a.
	collection add: b.
	self assert: (collection sorted: #id ascending) equals: {
			a.
			b }.
	self assert: (collection remove: a) identicalTo: a.
	self should: [ collection remove: a ] raise: NotFound
]

{ #category : 'testing' }
GolapClipCollectionTest >> testRemoveIfAbsent [

	collection add: a.
	collection add: b.
	self assert: (collection sorted: #id ascending) equals: {
			a.
			b }.
	self assert: (collection remove: a ifAbsent: [ nil ]) identicalTo: a.
	self assert: (collection remove: a ifAbsent: [ nil ]) equals: nil
]

{ #category : 'testing' }
GolapClipCollectionTest >> testRemoveKeyIfAbsent [

	collection add: a.
	collection add: b.
	self assert: (collection sorted: #id ascending) equals: {
			a.
			b }.
	self assert: (collection removeKey: 'a' ifAbsent: [ ]) identicalTo: a.
	self assert: (collection removeKey: 'a' ifAbsent: [ nil ]) equals: nil.
	self assert: (collection removeKey: b ifAbsent: [ nil ]) equals: nil
]

{ #category : 'testing' }
GolapClipCollectionTest >> testRenameTo [

	collection add: a.
	collection add: b.
	self assert: (collection sorted: #id ascending) equals: {
			a.
			b }.
	self assert: (collection rename: 'a' to: 'c') identicalTo: a.
	self assert: a id equals: 'c'.
	self assert: (collection at: 'c') identicalTo: a
]
