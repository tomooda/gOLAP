Class {
	#name : 'GolapProjectPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'projectList',
		'addProjectButton',
		'renameProjectButton',
		'removeProjectButton',
		'saveProjectButton',
		'switchProjectButton'
	],
	#classVars : [
		'Current'
	],
	#category : 'Golap-UI-Project',
	#package : 'Golap-UI',
	#tag : 'Project'
}

{ #category : 'sole instance' }
GolapProjectPresenter class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'menus' }
GolapProjectPresenter class >> golapMenuOn: aBuilder [

	<worldMenu>
	<golapMenu>
	(aBuilder item: #GolapOpenProjectPresenter)
		label: 'プロジェクト';
		iconName: #open;
		parent: #GolapFileMenu;
		order: 10;
		target: self;
		selector: #open;
		help: 'プロジェクトリストを開きます。'
]

{ #category : 'operations' }
GolapProjectPresenter class >> open [

	<script: 'GolapProjectPresenter open'>
	| window |
	self current updateProjectList.
	window := self current window ifNil: [ self current asWindow ].
	window isOpen
		ifTrue: [ window activate ]
		ifFalse: [
				window
					initialPosition:
						0 @ ((self currentWorld submorphs detect: [ :m | m top <= 1 ] ifNone: [ nil ]) ifNotNil: [ :m | m bottom ] ifNil: [ 0 ]);
					open ]
]

{ #category : 'operations' }
GolapProjectPresenter >> addProject [

	self confirmToSaveCurrentProject ifNotNil: [
			(self requestNewProject: '') ifNotNil: [ :project |
					project store.
					project beCurrent.
					self
						updateProjectList;
						selectProject: project ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> alert: aString title: anotherString [

	(self application newAlert
		 message: aString;
		 title: anotherString;
		 asModalWindow)
		initialExtent: 500 @ 120;
		open
]

{ #category : 'ui requests' }
GolapProjectPresenter >> confirm: queryString title: titleString [

	^ self application newConfirm
		  title: titleString;
		  message: queryString;
		  openModal
]

{ #category : 'operations' }
GolapProjectPresenter >> confirmToSaveCurrentProject [

	^ self currentProject ifDefault: [ false ] otherwise: [ :current |
			  (self confirmYesNoCancel: current projectName , 'を保存しますか？' title: '保存の確認') ifNotNil: [ :save |
					  save
						  ifTrue: [ current store ifNil: [ self alert: current projectName , 'の保存に失敗しました。' title: '保存失敗' ] ];
						  yourself ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> confirmYesNoCancel: aString title: anotherString [

	^ (GolapConfirmYesNoCancelDialog newApplication: self application)
		  message: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProject [

	^ GolapProject current
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectFile [

	^ self currentProject projectFile
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectName [

	^ self currentProject projectName
]

{ #category : 'layout' }
GolapProjectPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: projectList expand: true;
		  add: (SpBoxLayout newHorizontal
				   add: addProjectButton expand: true;
				   add: renameProjectButton expand: true;
				   add: removeProjectButton expand: true;
				   yourself)
		  expand: false;
		  add: saveProjectButton expand: false;
		  add: switchProjectButton expand: false;
		  yourself
]

{ #category : 'accessing' }
GolapProjectPresenter >> iconFor: aGolapProject [

	^ aGolapProject = self currentProject
		  ifTrue: [ self iconNamed: #accept ]
		  ifFalse: [ nil ]
]

{ #category : 'initialization' }
GolapProjectPresenter >> initializePresenters [

	super initializePresenters.
	projectList := self newTable
		               addColumn: ((SpImageTableColumn evaluated: [ :project | self iconFor: project ]) width: 32);
		               addColumn: (SpStringTableColumn title: 'プロジェクト名' evaluated: #projectName);
		               whenSelectedItemChangedDo: [ self selectedProjectChanged ];
		               yourself.
	projectList whenBuiltDo: [ :ann | ann widget allowDeselection ].
	addProjectButton := self newButton
		                    icon: (self iconNamed: #add);
		                    label: '作成';
		                    action: [ self addProject ];
		                    yourself.
	removeProjectButton := self newButton
		                       icon: (self iconNamed: #remove);
		                       label: '削除';
		                       action: [ self removeProject ];
		                       yourself.
	renameProjectButton := self newButton
		                       icon: (self iconNamed: #edit);
		                       label: '名前変更';
		                       action: [ self renameProject ];
		                       yourself.
	saveProjectButton := self newButton
		                     icon: (self iconNamed: #save);
		                     label: '保存';
		                     action: [ self saveProject ];
		                     yourself.
	switchProjectButton := self newButton
		                       icon: (self iconNamed: #accept);
		                       label: '開く';
		                       action: [ self switchProject ];
		                       yourself.
	self updateProjectList
]

{ #category : 'operations' }
GolapProjectPresenter >> removeProject [

	self selectedProject ifNotNil: [ :project |
			(self confirm: project projectName , 'を削除しますか？' title: 'プロジェクト削除') ifTrue: [
					project delete.
					self currentProject = project ifTrue: [ GolapProject default beCurrent ].
					self updateProjectList ] ]
]

{ #category : 'operations' }
GolapProjectPresenter >> renameProject [

	self selectedProject ifNotNil: [ :project |
			project = self currentProject ifTrue: [ project beCurrent ].
			(self requestNewProject: project projectName) ifNotNil: [ :newProject |
					project renameTo: newProject projectName.
					self updateProjectList ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> request: request initialAnswer: initialAnwser title: title [

	| answer |
	answer := self application newRequest
		          title: title;
		          message: request;
		          text: initialAnwser;
		          openModal.
	^ answer
]

{ #category : 'operations' }
GolapProjectPresenter >> requestNewProject: aString [

	| projectName project |
	[
		[
			projectName := self request: '新規プロジェクト名' initialAnswer: aString title: '新規プロジェクト作成'.
			projectName ifNil: [ ^ nil ].
			projectName := projectName trim.
			[ FileSystem disk checkName: projectName fixErrors: false ]
				on: Error
				do: [ :ex |
						self alert: 'ファイル名に使える名前を入力してください。' title: 'プロジェクト名エラー'.
						projectName := nil ].
			projectName isNil ] whileTrue.
		project := GolapProject named: projectName.
		project exists ifTrue: [
				self alert: 'そのプロジェクト名は既に使われています。' title: 'プロジェクト名エラー'.
				project := nil ].
		project isNil ] whileTrue.
	^ project
]

{ #category : 'operations' }
GolapProjectPresenter >> saveProject [

	self currentProject store ifNil: [ self alert: self currentProjectName , 'の保存に失敗しました。' title: '保存失敗' ]
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectProject: aGolapNamedProject [

	(projectList items includes: aGolapNamedProject)
		ifNotNil: [ :ref | projectList selectItem: aGolapNamedProject ]
		ifNil: [ projectList unselectAll ]
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProject [

	^ projectList selectedItem
]

{ #category : 'updating' }
GolapProjectPresenter >> selectedProjectChanged [

	self updateButtons
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProjectFile [

	^ self selectedProject ifNotNil: #projectFile
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProjectName [

	^ self selectedProject ifNotNil: #projectName
]

{ #category : 'operations' }
GolapProjectPresenter >> switchProject [

	self selectedProject ifNotNil: [ :project |
			project = self currentProject
				ifTrue: [ (self confirm: self currentProjectName , 'を再読み込みしますか？' title: '再読み込みの確認') ifFalse: [ ^ self ] ]
				ifFalse: [ self confirmToSaveCurrentProject ifNil: [ ^ self ] ].
			(project
				 beCurrent;
				 closeAll;
				 load) ifNil: [ self alert: self currentProjectName , 'の読み込みに失敗しました。' title: '読み込み失敗' ].
			self updateProjectList ]
]

{ #category : 'updating' }
GolapProjectPresenter >> updateButtons [

	| selected current |
	selected := self selectedProject.
	current := self currentProject.
	removeProjectButton enabled: selected notNil.
	renameProjectButton enabled: selected notNil.
	saveProjectButton enabled: (selected notNil and: [ selected = current ]).
	switchProjectButton enabled: selected notNil
]

{ #category : 'updating' }
GolapProjectPresenter >> updateProjectList [

	| selection |
	selection := projectList selectedItem.
	projectList items: GolapProject all.
	self selectProject: selection
]

{ #category : 'accessing' }
GolapProjectPresenter >> windowTitle [

	^ 'プロジェクト一覧'
]
