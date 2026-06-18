Class {
	#name : 'GolapNamedProject',
	#superclass : 'GolapAbstractProject',
	#instVars : [
		'projectFile'
	],
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'menus' }
GolapNamedProject class >> golapMenuOn: aBuilder [

	<worldMenu>
	<golapMenu>
	(aBuilder item: #GolapOpenProjectFile)
		label: 'プロジェクトを開く...';
		iconName: #open;
		parent: #GolapFileMenu;
		order: 20;
		target: self;
		selector: #open;
		help: 'プロジェクトファイルを開いて、グラフ分析状態を復元します。'.
	(aBuilder item: #GolapSaveProjectFile)
		label: 'プロジェクトを保存する...';
		iconName: #save;
		parent: #GolapFileMenu;
		order: 21;
		target: self;
		selector: #save;
		help: 'グラフ分析状態をプロジェクトファイルに保存します。';
		withSeparatorAfter.
	(aBuilder item: #GolapCloseProject)
		label: '終了';
		iconName: #smallQuit;
		parent: #GolapFileMenu;
		order: 99;
		target: self;
		selector: #quit;
		help: 'gOLAPを終了します。'
]

{ #category : 'operations' }
GolapNamedProject class >> open [

	self current open
]

{ #category : 'accessing' }
GolapNamedProject class >> projectBaseDirectory [

	^ self golapDirectory
]

{ #category : 'operations' }
GolapNamedProject class >> quit [

	self current quit
]

{ #category : 'operations' }
GolapNamedProject class >> save [

	self current save
]

{ #category : 'operations' }
GolapNamedProject >> closeAll [

	self golapWindows ifEmpty: [ ^ self ].
	(self
		 confirmYesNoCancel: 'プロジェクトを保存しますか？'
		 title: 'プロジェクト ' , (self projectName ifNil: [ 'なし' ])) ifNotNil: [
			:ans |
			ans ifTrue: [ self save ].
			self golapWindowsDo: [ :window | window presenter forceClose ] ]
]

{ #category : 'operations' }
GolapNamedProject >> load [

	self projectFile ifNotNil: [ :ref |
			ref readStreamDo: [ :stream |
					(NeoJSONReader on: stream) next ifNotNil: [ :json |
							self closeAll.
							self fromJSON: json ] ] ]
]

{ #category : 'operations' }
GolapNamedProject >> open [

	| dialog |
	dialog := StOpenFilePresenter new.
	dialog
		title: 'プロジェクトを開く';
		extensions: #( 'golap' ).
	projectFile
		ifNotNil: [
				dialog
					defaultFolder: projectFile parent;
					selectFile: projectFile ]
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
GolapNamedProject >> projectFile [

	^ projectFile
]

{ #category : 'accessing' }
GolapNamedProject >> projectFile: aFileReference [

	projectFile := aFileReference.
	self updateWorldWindowTitle
]

{ #category : 'accessing' }
GolapNamedProject >> projectName [

	^ projectFile ifNotNil: [
		  projectFile basenameWithoutExtension: self class fileExtension ]
]

{ #category : 'accessing' }
GolapNamedProject >> projectName: aString [

	self projectFile:
		(self class projectBaseDirectory / aString withExtension:
			 self class fileExtension)
]

{ #category : 'operations' }
GolapNamedProject >> quit [

	self closeAll.
	self projectFile: nil.
	Smalltalk snapshot: false andQuit: true
]

{ #category : 'operations' }
GolapNamedProject >> save [

	(self golapWindows notEmpty or: [
		 self confirm: '空のプロジェクトを保存しますか？' title: 'プロジェクト保存' ]) ifTrue: [
			| dialog |
			dialog := StSaveFilePresenter new.
			dialog
				title: 'プロジェクトを保存する';
				extensions: #( 'golap' ).
			projectFile
				ifNotNil: [
						dialog
							defaultFolder: projectFile parent;
							selectFile: projectFile ]
				ifNil: [ dialog defaultFolder: self class projectBaseDirectory ].
			dialog openModal.
			dialog cancelled ifFalse: [
					dialog selectedEntry ifNotNil: [ :ref |
							projectFile := ref.
							self store ] ] ]
]

{ #category : 'operations' }
GolapNamedProject >> store [

	projectFile ifNotNil: [
			self asJSON ifNotNil: [ :json |
					projectFile writeStreamDo: [ :stream |
							stream truncate.
							(NeoJSONWriter on: stream)
								prettyPrint: true;
								nextPut: json ] ] ]
]

{ #category : 'updating' }
GolapNamedProject >> updateMenubar [

	GolapMenubar reset
]

{ #category : 'updating' }
GolapNamedProject >> updateWorldWindowTitle [

	self currentWorld worldState worldRenderer osWindow title:
		(self projectName ifNil: [ 'gOLAP' ])
]
