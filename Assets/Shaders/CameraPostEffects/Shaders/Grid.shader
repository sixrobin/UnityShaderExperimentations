// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Grid" {

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_gridColor("Grid Color", float) = 0
		_scaleX("_scaleX", int) = 10
		_scaleY("_scaleY", int) = 10
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	v2f vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}
			
	sampler2D _MainTex;
	float4 _gridColor;
	int _scaleX;
	int _scaleY;

	fixed4 frag (v2f i) : SV_Target
	{
		float4 sum = (float4)0;
		sum = tex2D(_MainTex, i.uv);

		float x = i.uv.x;
		float y = i.uv.y;

		float4 color = _gridColor;

		x = x * _ScreenParams.xy.x;
		uint x2 = int(x);
		y = y * _ScreenParams.xy.y;
		uint y2 = int(y);
			
		fixed3 col = fixed3((color.x - sum.r), (color.y - sum.g), (color.z - sum.b));

		if(x2%_scaleX == 0)
			sum = float4(sum.r + col.x, sum.g + col.y, sum.b + col.z, 1);
				
		if(y2%_scaleY == 0)			
			sum = float4(sum.r + col.x, sum.g + col.y, sum.b + col.z, 1);
				
		return fixed4(sum);
	}

	ENDCG

	SubShader 
	{
		Pass 
		{
			ZTest Always
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
