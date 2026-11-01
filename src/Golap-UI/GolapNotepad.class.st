Class {
	#name : 'GolapNotepad',
	#superclass : 'SpPresenter',
	#traits : 'TGolapSnapshotablePresenter',
	#classTraits : 'TGolapSnapshotablePresenter classTrait',
	#instVars : [
		'sourceText',
		'preview',
		'notebook',
		'exportButton',
		'closeButton'
	],
	#category : 'Golap-UI-Notepad',
	#package : 'Golap-UI',
	#tag : 'Notepad'
}

{ #category : 'layout' }
GolapNotepad >> defaultLayout [

	<script: 'self new open'>
	^ SpBoxLayout newVertical
		  add: notebook;
		  add: (SpBoxLayout newHorizontal
				   hAlignEnd;
				   add: exportButton expand: false;
				   add: closeButton expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'operations' }
GolapNotepad >> export [

	self alert: '未実装'
]

{ #category : 'initialization' }
GolapNotepad >> initializePresenters [

	super initializePresenters.
	sourceText := self newText
		              whenTextChangedDo: [ self sourceTextChanged ];
		              yourself.
	preview := self instantiate: GolapMicrodownPresenter.
	notebook := self newNotebook
		            addPageTitle: 'プレビュー' provider: [ preview ];
		            addPageTitle: '編集' provider: [ sourceText ];
		            whenSelectedPageChangedDo: [ self updatePages ];
		            yourself.
	closeButton := self newButton
		               label: '閉じる';
		               action: [ self close ];
		               yourself.
	exportButton := self newButton
		                label: 'エキスポート';
		                action: [ self export ];
		                yourself
]

{ #category : 'initialization' }
GolapNotepad >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter
		title: 'ノート';
		initialExtent: 600 @ self currentWorld extent y;
		initialPosition: 0 @ 20.
	aSpWindowPresenter
		whenOpenedDo: [ self setupSubscription ];
		whenClosedDo: [ self releaseSubscription ]
]

{ #category : 'accessing' }
GolapNotepad >> note [

	^ GolapNote current
]

{ #category : 'subscription' }
GolapNotepad >> releaseSubscription [

	self note ifNotNil: [ :note | note announcer unsubscribe: self ].
	GolapProject announcer unsubscribe: self
]

{ #category : 'operations' }
GolapNotepad >> save [

	self alert: '未実装'
]

{ #category : 'subscription' }
GolapNotepad >> setupSubscription [

	self note ifNotNil: [ :note | note announcer when: GolapNoteModified send: #updatePages to: self ].
	GolapProject announcer when: GolapNoteReplaced send: #updateNoteSubscription: to: self
]

{ #category : 'updating' }
GolapNotepad >> sourceTextChanged [

	self note string: sourceText text
]

{ #category : 'subscription' }
GolapNotepad >> updateNoteSubscription: aGolapNoteReplaced [

	aGolapNoteReplaced oldNote ifNotNil: [ :note | note announcer unsubscribe: self ].
	aGolapNoteReplaced newNote ifNotNil: [ :note | note announcer when: GolapNoteModified send: #updatePages to: self ]
]

{ #category : 'updating' }
GolapNotepad >> updatePages [

	sourceText isDisplayed ifTrue: [ self updateSourceText ].
	preview isDisplayed ifTrue: [ self updatePreview ]
]

{ #category : 'updating' }
GolapNotepad >> updatePreview [

	preview documentFromString: self note string
]

{ #category : 'updating' }
GolapNotepad >> updateSourceText [

	| newSource |
	(newSource := self note string) ~= sourceText text ifTrue: [ sourceText text: newSource ]
]
