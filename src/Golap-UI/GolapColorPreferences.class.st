Class {
	#name : 'GolapColorPreferences',
	#superclass : 'Object',
	#instVars : [
		'normalColor',
		'selectionColor',
		'retreatingColor',
		'decliningColor',
		'freshColor',
		'growingColor',
		'positivePolishColor',
		'negativePolishColor'
	],
	#classVars : [
		'NamedColors'
	],
	#classInstVars : [
		'normalColor',
		'selectionColor',
		'retreatingColor',
		'decliningColor',
		'freshColor',
		'growingColor',
		'positivePolishColor',
		'negativePolishColor'
	],
	#category : 'Golap-UI-Preferences',
	#package : 'Golap-UI',
	#tag : 'Preferences'
}

{ #category : 'JSON' }
GolapColorPreferences class >> asJSON [

	^ {
		  ('normalColor' -> normalColor asHexString).
		  ('selectionColor' -> selectionColor asHexString).
		  ('positivePolishColor' -> positivePolishColor asHexString).
		  ('negativePolishColor' -> negativePolishColor asHexString).
		  ('growingColor' -> growingColor asHexString).
		  ('decliningColor' -> decliningColor asHexString).
		  ('freshColor' -> freshColor asHexString).
		  ('retreatingColor' -> retreatingColor asHexString) }
		  asOrderedDictionary
]

{ #category : 'accessing' }
GolapColorPreferences class >> decliningColor [

	^ decliningColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> decliningColor: aColor [

	decliningColor := aColor.
	self updateGolap
]

{ #category : 'accessing' }
GolapColorPreferences class >> freshColor [

	^ freshColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> freshColor: aColor [

	freshColor := aColor.
	self updateGolap
]

{ #category : 'JSON' }
GolapColorPreferences class >> fromJSON: aDictionary [

	aDictionary
		at: 'normalColor'
		ifPresent: [ :hex | normalColor := Color fromHexString: hex ];
		at: 'selectionColor'
		ifPresent: [ :hex | selectionColor := Color fromHexString: hex ];
		at: 'positivePolishColor'
		ifPresent: [ :hex | positivePolishColor := Color fromHexString: hex ];
		at: 'negativePolishColor'
		ifPresent: [ :hex | negativePolishColor := Color fromHexString: hex ];
		at: 'growingColor'
		ifPresent: [ :hex | growingColor := Color fromHexString: hex ];
		at: 'decliningColor'
		ifPresent: [ :hex | decliningColor := Color fromHexString: hex ];
		at: 'freshColor'
		ifPresent: [ :hex | freshColor := Color fromHexString: hex ];
		at: 'retreatingColor'
		ifPresent: [ :hex | retreatingColor := Color fromHexString: hex ]
]

{ #category : 'settings' }
GolapColorPreferences class >> golapSettingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #'gOLAP-colors')
		label: 'Colors';
		parent: #gOLAP;
		description: 'Color settings';
		target: self;
		noOrdering;
		with: [
				(aBuilder button: #resetToDefault)
					label: 'デフォルトに戻す';
					buttonLabel: 'デフォルトに戻す';
					description: '色に関する現在の設定を捨ててデフォルトに戻します。'.
				(aBuilder setting: #normalColor)
					label: '通常';
					description: '通常の商品や関連を描画する色'.
				(aBuilder setting: #selectionColor)
					label: '選択';
					description: '選択された商品や関連を描画する色'.
				(aBuilder setting: #positivePolishColor)
					label: '＋研磨';
					description: '研磨で追加された関連を描画する色'.
				(aBuilder setting: #negativePolishColor)
					label: 'ー研磨';
					description: '研磨で追加された関連を描画する色'.
				(aBuilder setting: #freshColor)
					label: '差分で追加';
					description: '差分で追加された商品や関連を描画する色'.
				(aBuilder setting: #retreatingColor)
					label: '差分で消滅';
					description: '差分で消えた商品や関連を描画する色'.
				(aBuilder setting: #growingColor)
					label: '＋差分';
					description: '値が増加した商品や関連を描画する色'.
				(aBuilder setting: #decliningColor)
					label: 'ー差分';
					description: '値が減少した商品や関連を描画する色' ]
]

{ #category : 'accessing' }
GolapColorPreferences class >> growingColor [

	^ growingColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> growingColor: aColor [

	growingColor := aColor.
	self updateGolap
]

{ #category : 'class initialization' }
GolapColorPreferences class >> initialize [

	self resetToDefault
]

{ #category : 'accessing' }
GolapColorPreferences class >> negativePolishColor [

	^ negativePolishColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> negativePolishColor: aColor [

	negativePolishColor := aColor.
	self updateGolap
]

{ #category : 'accessing' }
GolapColorPreferences class >> normalColor [

	^ normalColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> normalColor: aColor [

	normalColor := aColor.
	self updateGolap
]

{ #category : 'accessing' }
GolapColorPreferences class >> normalColorFor: aGolapNode [

	^ self normalColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> positivePolishColor [

	^ positivePolishColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> positivePolishColor: aColor [

	positivePolishColor := aColor.
	self updateGolap
]

{ #category : 'class initialization' }
GolapColorPreferences class >> resetToDefault [

	normalColor := Color gray.
	selectionColor := Color black.
	positivePolishColor := Color cyan.
	negativePolishColor := Color cyan.
	freshColor := Color blue.
	growingColor := Color blue muchDarker.
	decliningColor := Color red muchDarker.
	retreatingColor := Color red.
	SettingBrowser refreshAllSettingBrowsers.
	self updateGolap
]

{ #category : 'accessing' }
GolapColorPreferences class >> retreatingColor [

	^ retreatingColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> retreatingColor: aColor [

	retreatingColor := aColor.
	self updateGolap
]

{ #category : 'accessing' }
GolapColorPreferences class >> selectionColor [

	^ selectionColor
]

{ #category : 'accessing' }
GolapColorPreferences class >> selectionColor: aColor [

	selectionColor := aColor.
	self updateGolap
]

{ #category : 'updating' }
GolapColorPreferences class >> updateGolap [

	self currentWorld taskbars do: [ :taskbar |
			taskbar submorphs do: [ :morph |
					([ morph model model presenter ]
						 on: MessageNotUnderstood
						 do: [ :ex | ex return: nil ]) ifNotNil: [ :p |
						p class = Golap ifTrue: [ p updateModel ] ] ] ]
]
