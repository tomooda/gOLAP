Class {
	#name : 'GolapProject',
	#superclass : 'Object',
	#instVars : [
		'note'
	],
	#classVars : [
		'Current',
		'announcer'
	],
	#category : 'Golap-Project-Core',
	#package : 'Golap-Project',
	#tag : 'Core'
}

{ #category : 'accessing' }
GolapProject class >> all [

	^ self projectFiles collect: [ :ref | self on: ref ]
]

{ #category : 'announcements' }
GolapProject class >> announceNoteReplaced: old with: new [

	self announcer announce: (GolapNoteReplaced new
			 oldNote: old;
			 newNote: new;
			 yourself)
]

{ #category : 'accessing' }
GolapProject class >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : 'instance creation' }
GolapProject class >> asJSON [

	^ self current ifNotNil: #asJSON
]

{ #category : 'accessing' }
GolapProject class >> current [

	<script: 'GolapProject current inspect'>
	^ Current ifNil: [
			  self current: self default.
			  Current ]
]

{ #category : 'accessing' }
GolapProject class >> current: aGolapProject [

	| old |
	old := Current.
	Current := aGolapProject.
	aGolapProject updateWorldWindowTitle.
	old ~~ Current ifTrue: [ self announceNoteReplaced: (old ifNotNil: #note) with: Current note ]
]

{ #category : 'accessing' }
GolapProject class >> currentProjectFile [

	^ self current projectFile
]

{ #category : 'accessing' }
GolapProject class >> currentProjectName [

	^ self current projectName
]

{ #category : 'instance creation' }
GolapProject class >> default [

	^ GolapDefaultProject new
]

{ #category : 'accessing' }
GolapProject class >> fileExtension [

	^ 'golap'
]

{ #category : 'accessing' }
GolapProject class >> flushCurrent [

	Current := nil
]

{ #category : 'instance creation' }
GolapProject class >> fromJSON: aDictionary [

	^ GolapNamedProject new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : 'accessing' }
GolapProject class >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'instance creation' }
GolapProject class >> named: aString [

	^ GolapNamedProject named: aString
]

{ #category : 'instance creation' }
GolapProject class >> on: aFileReferenceOrNil [

	^ aFileReferenceOrNil ifNil: [ self default ] ifNotNil: [ GolapNamedProject on: aFileReferenceOrNil ]
]

{ #category : 'accessing' }
GolapProject class >> projectFiles [

	^ ((self golapDirectory filesMatching: '*.' , self fileExtension) reject: [ :ref | ref basename beginsWith: '.' ]) sorted
]

{ #category : 'ui requests' }
GolapProject >> application [

	^ SpApplication defaultApplication
]

{ #category : 'operations' }
GolapProject >> beCurrent [

	self class current: self
]

{ #category : 'ui requests' }
GolapProject >> confirm: aString title: anotherString [

	^ self application newConfirm
		  message: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'operations' }
GolapProject >> delete [

	self projectFile ifNotNil: #ensureDelete
]

{ #category : 'testing' }
GolapProject >> exists [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapProject >> fromJSON: aDictionary [

	aDictionary
		at: 'last-query' ifPresent: [ :query | self restoreQuery: query ];
		at: 'note' ifPresent: [ :dict | dict ifNotNil: [ self note fromJSON: dict ] ]
]

{ #category : 'controlling' }
GolapProject >> ifDefault: aBlock otherwise: anotherBlock [

	^ self subclassResponsibility
]

{ #category : 'operations' }
GolapProject >> load [

	^ self projectFile ifNotNil: [ :ref | ref readStreamDo: [ :stream | self fromJSON: (GolapJSON fromStream: stream) ] ]
]

{ #category : 'accessing' }
GolapProject >> note [

	^ note ifNil: [ note := GolapNote new ]
]

{ #category : 'accessing' }
GolapProject >> note: aGolapNote [

	note := aGolapNote
]

{ #category : 'accessing' }
GolapProject >> projectFile [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapProject >> projectFile: aFileReference [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapProject >> projectName [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapProject >> projectName: aString [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapProject >> restoreQuery: aDictionary [

	[ GolapNetworkClientPresenter fromJSON: aDictionary ]
		on: Exception
		do: [ :ex |
				GolapNetworkClientPresenter flushCurrent.
				ex pass ]
]

{ #category : 'converting' }
GolapProject >> restoreWindows: anArray [

	anArray do: [ :json |
			json at: 'class' ifPresent: [ :className |
					(TGolapSnapshotablePresenter users detect: [ :class | class name asString = className ] ifNone: [ nil ]) ifNotNil: [ :class |
						class fromJSON: json ] ] ]
]

{ #category : 'operations' }
GolapProject >> save [

	| dialog |
	dialog := StSaveFilePresenter new.
	dialog
		title: 'プロジェクトを保存する';
		extensions: #( 'golap' ).
	self projectFile
		ifNotNil: [ :ref |
				dialog
					defaultFolder: ref parent;
					selectFile: ref ]
		ifNil: [ dialog defaultFolder: self class projectBaseDirectory ].
	dialog openModal.
	dialog cancelled ifFalse: [
			dialog selectedEntry ifNotNil: [ :ref |
					self projectFile: ref.
					self store ] ]
]

{ #category : 'operations' }
GolapProject >> store [

	^ self projectFile ifNotNil: [ :ref |
			  self asJSON ifNotNil: [ :json |
					  ref writeStreamDo: [ :stream |
							  stream truncate.
							  GolapJSON put: json onStream: stream ] ] ]
]

{ #category : 'converting' }
GolapProject >> toJSON: aDictionary [

	GolapNetworkClientPresenter asJSON ifNotNil: [ :query | aDictionary at: 'last-query' put: query ].
	aDictionary at: 'note' put: self note asJSON
]

{ #category : 'updating' }
GolapProject >> updateWorldWindowTitle [

	self currentWorld worldState worldRenderer osWindow title:
		(self projectName ifNil: [ 'gOLAP' ])
]
