Class {
	#name : 'GolapNote',
	#superclass : 'Object',
	#instVars : [
		'clipCollection',
		'string',
		'dirty'
	],
	#category : 'Golap-Notepad-Core',
	#package : 'Golap-Notepad',
	#tag : 'Core'
}

{ #category : 'operations' }
GolapNote >> addClip: aGolapClip [

	(clipCollection includes: aGolapClip) ifTrue: [ ^ nil ].
	^ (self validateId: aGolapClip id) ifNotNil: [ :id |
			  aGolapClip id: id.
			  clipCollection add: aGolapClip.
			  self clipCollectionChanged.
			  aGolapClip ]
]

{ #category : 'operations' }
GolapNote >> clearDirty [

	dirty := false
]

{ #category : 'updating' }
GolapNote >> clipCollectionChanged [

	dirty := true
]

{ #category : 'accessing' }
GolapNote >> findUnusedId [

	| max |
	max := 0.
	clipCollection do: [ :clip |
		(clip id beginsWith: 'クリップ') ifTrue: [ max := max max: (clip id copyFrom: 5 to: clip id size) asInteger abs ] ].
	^ ('クリップ' , max + 1) printString
]

{ #category : 'initialization' }
GolapNote >> initialize [

	super initialize.
	string := String new.
	clipCollection := GolapClipCollection new.
	dirty := false
]

{ #category : 'testing' }
GolapNote >> isDirty [

	^ dirty = true
]

{ #category : 'operations' }
GolapNote >> removeClip: aGolapClip [

	^ (clipCollection remove: aGolapClip ifAbsent: [ nil ]) ifNotNil: [ :clip |
			  self clipCollectionChanged.
			  clip ]
]

{ #category : 'operations' }
GolapNote >> renameClip: aGolapClip [

	^ (self validateId: (self requestId: aGolapClip id message: '新しい名前を入力してください')) ifNotNil: [ :newId |
			  clipCollection rename: aGolapClip id to: newId.
			  self clipCollectionChanged.
			  aGolapClip ]
]

{ #category : 'ui requests' }
GolapNote >> requestId: aStringOrNil message: anotherString [

	^ SpApplication defaultApplication newRequest
		  title: '名前入力';
		  label: anotherString;
		  text: (aStringOrNil ifNil: [ self findUnusedId ]);
		  openModal
]

{ #category : 'accessing' }
GolapNote >> string [

	^ string
]

{ #category : 'accessing' }
GolapNote >> string: aString [

	string := aString.
	self stringChanged
]

{ #category : 'updating' }
GolapNote >> stringChanged [

	dirty := true
]

{ #category : 'private' }
GolapNote >> validateId: aString [

	| badChars id |
	badChars := #( $: $< $> $| $/ $\ $? $* $" ) asSet.
	id := aString ifNotNil: #trim.
	id isNil ifTrue: [ (id := self requestId: aString message: '名前を入力してください') ifNil: [ ^ nil ] ].
	[ id isEmpty ] whileTrue: [ id := (self requestId: id message: '名前を入力してください') ifNil: [ ^ nil ] ].
	[
		| ok |
		ok := true.
		ok := ok and: [
				      id size <= 100 or: [
						      (id := self requestId: id message: '100文字以内で名前を入力してください') ifNil: [ ^ nil ].
						      false ] ].
		ok := ok and: [
				      (id allSatisfy: [ :char | (badChars includes: char) not ]) or: [
						      (id := self requestId: id message: ': < > | / \ ? * " を含まない名前を入力してください') ifNil: [ ^ nil ].
						      false ] ].
		ok ] whileFalse.
	^ id
]
