Class {
	#name : 'GolapNamedProject',
	#superclass : 'GolapProject',
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

{ #category : 'converting' }
GolapNamedProject >> asJSON [

	^ super asJSON
		  at: 'project' put: self projectName;
		  yourself
]

{ #category : 'converting' }
GolapNamedProject >> fromJSON: aDictionaryOrNil [

	aDictionaryOrNil at: 'project' ifPresent: [ :projectName | self projectName: projectName ].
	super fromJSON: aDictionaryOrNil
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

{ #category : 'updating' }
GolapNamedProject >> updateMenubar [

	GolapMenubar reset
]
