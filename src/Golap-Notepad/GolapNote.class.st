Class {
	#name : 'GolapNote',
	#superclass : 'Model',
	#instVars : [
		'clipCollection',
		'string',
		'dirty'
	],
	#category : 'Golap-Notepad-Core',
	#package : 'Golap-Notepad',
	#tag : 'Core'
}

{ #category : 'utilities' }
GolapNote class >> current [

	^ GolapProject current note
]

{ #category : 'instance creation' }
GolapNote class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : 'operations' }
GolapNote >> addClip: aGolapClip [

	^ (self basicAddClip: aGolapClip) ifNotNil: [ :clip |
			  self announceNoteChanged.
			  clip ]
]

{ #category : 'announcements' }
GolapNote >> announceNoteChanged [

	^ self announcer announce: (GolapNoteModified on: self)
]

{ #category : 'operations' }
GolapNote >> appendClip: aGolapClip [

	(self basicAddClip: aGolapClip) ifNotNil: [ :clip |
			self appendString: aGolapClip asMicrodown.
			self announceNoteChanged ]
]

{ #category : 'operations' }
GolapNote >> appendString: aString [

	string := string , String cr , aString
]

{ #category : 'converting' }
GolapNote >> asJSON [

	| json |
	json := Dictionary new.
	self toJSON: json.
	^ json
]

{ #category : 'operations' }
GolapNote >> basicAddClip: aGolapClip [

	(clipCollection includes: aGolapClip) ifTrue: [ ^ nil ].
	^ (self validateId: aGolapClip id) ifNotNil: [ :id |
			  aGolapClip id: id.
			  clipCollection add: aGolapClip.
			  aGolapClip ]
]

{ #category : 'operations' }
GolapNote >> clearDirty [

	dirty := false
]

{ #category : 'accessing' }
GolapNote >> clipAt: aString ifAbsent: absentBlock [

	^ clipCollection at: aString ifAbsent: absentBlock
]

{ #category : 'accessing' }
GolapNote >> clipAt: aString ifPresent: presentBlock ifAbsent: absentBlock [

	^ clipCollection at: aString ifPresent: presentBlock ifAbsent: absentBlock
]

{ #category : 'updating' }
GolapNote >> clipCollectionChanged [

	dirty := true.
	self announceNoteChanged
]

{ #category : 'private' }
GolapNote >> findUnusedId [

	| max |
	max := 0.
	clipCollection do: [ :clip |
		(clip id beginsWith: 'クリップ') ifTrue: [ max := max max: (clip id copyFrom: 5 to: clip id size) asInteger abs ] ].
	^ 'クリップ' , (max + 1) printString
]

{ #category : 'converting' }
GolapNote >> fromJSON: aDictionary [

	aDictionary
		at: 'string' ifPresent: [ :str | string := str ];
		at: 'clips' ifPresent: [ :array |
				clipCollection := GolapClipCollection new: array size.
				array do: [ :dict | (GolapClip fromJSON: dict) ifNotNil: [ :clip | clipCollection add: clip ] ] ]
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
		  message: anotherString;
		  text: (aStringOrNil ifNil: [ self findUnusedId ]);
		  openModal
]

{ #category : 'accessing' }
GolapNote >> string [

	^ string
]

{ #category : 'accessing' }
GolapNote >> string: aString [

	string ~= aString ifTrue: [
			string := aString.
			self stringChanged ]
]

{ #category : 'updating' }
GolapNote >> stringChanged [

	dirty := true.
	self announceNoteChanged
]

{ #category : 'accessing' }
GolapNote >> text [

	^ self textFromMicrodown: self string
]

{ #category : 'private' }
GolapNote >> textFromMicrodown: aString [

	^ MicRichTextComposer new
		  textStyler: GolapMicTextStyler new;
		  asRichText: (MicrodownParser new parse: aString)
]

{ #category : 'converting' }
GolapNote >> toJSON: aDictionary [

	aDictionary
		at: 'string' put: string;
		at: 'clips' put: (clipCollection asArray collect: #asJSON)
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
