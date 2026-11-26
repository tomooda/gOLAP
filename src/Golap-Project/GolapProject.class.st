Class {
	#name : 'GolapProject',
	#superclass : 'Object',
	#traits : 'TComparable',
	#classTraits : 'TComparable classTrait',
	#instVars : [
		'projectFile',
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

{ #category : 'accessing' }
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

	^ self new
]

{ #category : 'accessing' }
GolapProject class >> fileExtension [

	^ 'golap'
]

{ #category : 'accessing' }
GolapProject class >> flushCurrent [

	<script>
	Current := nil
]

{ #category : 'instance creation' }
GolapProject class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : 'accessing' }
GolapProject class >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'instance creation' }
GolapProject class >> named: aString [

	^ self new
		  projectName: aString;
		  yourself
]

{ #category : 'instance creation' }
GolapProject class >> on: aFileReference [

	^ self new
		  projectFile: aFileReference;
		  yourself
]

{ #category : 'operations' }
GolapProject class >> open [

	self current open
]

{ #category : 'accessing' }
GolapProject class >> projectBaseDirectory [

	^ self golapDirectory
]

{ #category : 'accessing' }
GolapProject class >> projectFiles [

	^ ((self golapDirectory filesMatching: '*.' , self fileExtension) reject: [ :ref | ref basename beginsWith: '.' ]) sorted
]

{ #category : 'operations' }
GolapProject class >> save [

	self current save
]

{ #category : 'comparing' }
GolapProject >> < aComparable [
	"Answer whether the receiver is less than the argument."

	^ self projectName < aComparable projectName
]

{ #category : 'comparing' }
GolapProject >> = anObject [

	^ self class = anObject class and: [ self projectName = anObject projectName ]
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

	^ projectFile notNil and: [ projectFile exists ]
]

{ #category : 'converting' }
GolapProject >> fromJSON: aDictionary [

	aDictionary
		at: 'last-query' ifPresent: [ :query | self restoreQuery: query ];
		at: 'note' ifPresent: [ :dict | dict ifNotNil: [ self note fromJSON: dict ] ]
]

{ #category : 'comparing' }
GolapProject >> hash [

	^ self class hash bitXor: self projectName hash
]

{ #category : 'controlling' }
GolapProject >> ifDefault: aBlock otherwise: anotherBlock [

	^ projectFile ifNil: [ aBlock cull: self ] ifNotNil: [ aBlock cull: self ]
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

	^ projectFile
]

{ #category : 'accessing' }
GolapProject >> projectFile: aFileReference [

	projectFile := aFileReference
]

{ #category : 'accessing' }
GolapProject >> projectName [

	^ projectFile ifNotNil: [ projectFile basenameWithoutExtension: self class fileExtension ]
]

{ #category : 'accessing' }
GolapProject >> projectName: aString [

	self projectFile: (self class projectBaseDirectory / aString withExtension: self class fileExtension)
]

{ #category : 'operations' }
GolapProject >> renameTo: aString [

	self projectFile ifNotNil: [ :oldRef |
			self projectName: aString.
			self projectFile ifNotNil: [ :newRef | oldRef moveTo: newRef ] ]
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
