Class {
	#name : 'GolapProject',
	#superclass : 'Object',
	#classVars : [
		'Current'
	],
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'accessing' }
GolapProject class >> all [

	^ self projectFiles collect: [ :ref | self on: ref ]
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

	Current := aGolapProject.
	aGolapProject updateWorldWindowTitle
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

	^ (aDictionary at: 'project' ifPresent: [ :string | self named: string ] ifAbsent: [ self default ])
		  fromJSON: aDictionary;
		  beCurrent;
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

{ #category : 'converting' }
GolapProject >> asJSON [

	| json |
	json := Dictionary new.
	GolapNetworkClientPresenter asJSON ifNotNil: [ :query |
		json at: 'last-query' put: query ].
	json at: 'windows' put: (Array streamContents: [ :stream |
				 self golapWindows do: [ :window |
					 stream nextPut: window presenter asJSON ] ]).
	^ json
]

{ #category : 'operations' }
GolapProject >> beCurrent [

	self class current: self
]

{ #category : 'operations' }
GolapProject >> closeAll [

	self golapWindowsDo: [ :window | window presenter forceClose ]
]

{ #category : 'ui requests' }
GolapProject >> confirm: aString title: anotherString [

	^ self application newConfirm
		  label: aString;
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

	aDictionary ifNotNil: [
			aDictionary isArray ifTrue: [ ^ self restoreWindows: aDictionary ].
			aDictionary
				at: 'last-query' ifPresent: [ :query | self restoreQuery: query ];
				at: 'windows' ifPresent: [ :array | self restoreWindows: array ] ]
]

{ #category : 'accessing' }
GolapProject >> golapWindows [

	^ Array streamContents: [ :stream |
		  self golapWindowsDo: [ :window | stream nextPut: window ] ]
]

{ #category : 'enumerating' }
GolapProject >> golapWindowsDo: aBlock [

	| presenterClasses |
	presenterClasses := TGolapSnapshotablePresenter users.
	self currentWorld taskbars do: [ :taskbar |
			taskbar submorphs do: [ :morph |
					([ morph model model presenter ]
						 on: MessageNotUnderstood
						 do: [ :ex | ex return: nil ]) ifNotNil: [ :p |
						(presenterClasses includes: p class) ifTrue: [
							aBlock value: p window ] ] ] ]
]

{ #category : 'controlling' }
GolapProject >> ifDefault: aBlock otherwise: anotherBlock [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapProject >> isEmpty [

	self golapWindowsDo: [ :window | ^ false ].
	^ true
]

{ #category : 'operations' }
GolapProject >> load [

	^ self projectFile ifNotNil: [ :ref |
			  [ ref readStreamDo: [ :stream | self fromJSON: (GolapJSON fromStream: stream) ] ]
				  on: Exception
				  do: [ :ex | ex return: nil ] ]
]

{ #category : 'testing' }
GolapProject >> notEmpty [

	^ self isEmpty not
]

{ #category : 'operations' }
GolapProject >> open [

	| dialog |
	dialog := StOpenFilePresenter new.
	dialog
		title: 'プロジェクトを開く';
		extensions: #( 'golap' ).
	self projectFile
		ifNotNil: [ :ref |
				dialog
					defaultFolder: ref parent;
					selectFile: ref ]
		ifNil: [ dialog defaultFolder: self class projectBaseDirectory ].
	dialog openModal.
	^ dialog cancelled
		  ifTrue: [ nil ]
		  ifFalse: [
				  dialog selectedEntry ifNotNil: [ :ref |
						  self projectFile: ref.
						  self load ] ]
]

{ #category : 'accessing' }
GolapProject >> projectFile [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapProject >> projectName [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapProject >> restoreQuery: aDictionary [

	| dialog |
	dialog := GolapProgressDialog new.
	dialog
		title: 'クエリ復元中...';
		informUserDuring: [ :progress |
				[ GolapNetworkClientPresenter fromJSON: aDictionary ]
					on: Exception
					do: [ :ex |
							GolapNetworkClientPresenter flushCurrent.
							ex pass ] ]
]

{ #category : 'converting' }
GolapProject >> restoreWindows: anArray [

	| dialog |
	dialog := GolapProgressDialog new.
	dialog
		title: '復元中...';
		informUserDuring: [ :progress |
				| widget |
				widget := dialog adapter widget.
				anArray withIndexDo: [ :json :index |
							progress progressPercent: index * 100 // anArray size.
							json at: 'class' ifPresent: [ :className |
										(TGolapSnapshotablePresenter users detect: [ :class | class name asString = className ] ifNone: [ nil ]) ifNotNil: [
												:class | class fromJSON: json ] ] ] ]
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
							  GolapJSON put: json onStreamPretty: stream ] ] ]
]

{ #category : 'updating' }
GolapProject >> updateWorldWindowTitle [

	self currentWorld worldState worldRenderer osWindow title:
		(self projectName ifNil: [ 'gOLAP' ])
]
