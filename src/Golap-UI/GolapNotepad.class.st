Class {
	#name : 'GolapNotepad',
	#superclass : 'SpPresenter',
	#instVars : [
		'sourceText',
		'preview',
		'notebook',
		'exportButton',
		'closeButton'
	],
	#classVars : [
		'Current'
	],
	#category : 'Golap-UI-Notepad',
	#package : 'Golap-UI',
	#tag : 'Notepad'
}

{ #category : 'sole instance' }
GolapNotepad class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'menus' }
GolapNotepad class >> golapMenuOn: aBuilder [

	<worldMenu>
	<golapMenu>
	(aBuilder item: #GolapOpenNotepad)
		label: 'ノート';
		iconName: #workspace;
		parent: #Golap;
		order: 0.1;
		target: self;
		selector: #open;
		help: 'ノートを開きます。'
]

{ #category : 'operations' }
GolapNotepad class >> open [

	<script: 'GolapNotepad open'>
	| window |
	window := self current window ifNil: [ self current asWindow ].
	window isOpen
		ifTrue: [ window activate ]
		ifFalse: [
				window
					title: 'ノート';
					initialExtent: 600 @ self currentWorld extent y;
					initialPosition: 0 @ 20;
					open ]
]

{ #category : 'initialization' }
GolapNotepad >> close [

	self window ifNotNil: #close
]

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
		whenOpenedDo: [
				self setupSubscription.
				self updatePages ];
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
