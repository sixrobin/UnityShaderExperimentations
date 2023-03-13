// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Diplopy" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_axisR ("Axis Red", int) = 0
		_amplitudeRed("AmplitudeRed", float) = 0
		_axisG ("Axis Green", int) = 0
		_amplitudeGreen("AmplitudeGreen", float) = 0
		_axisB("Axis Blue", int) = 0
		_amplitudeBlue("AmplitudeBlue", float) = 0
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;

	int _axisR;
	float _amplitudeRed;

	int _axisG;
	float _amplitudeGreen;

	int _axisB;
	float _amplitudeBlue;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float2 axisR[4] =
		{
			-1, 1,
			1, 1,
			-1, 0,
			0, 1	
		};

		float2 axisG[4] =
		{
			-1, 1,
			1, 1,
			-1, 0,
			0, 1
		};

		float2 axisB[4] =
		{
			-1, 1,
			1, 1,
			-1, 0,
			0, 1
		};

		float4 sum = (float4)0;
		sum = tex2D(_MainTex, i.uv);

		sum += tex2D(_MainTex, i.uv + _amplitudeRed/100 * axisR[_axisR]) * float4(1, 0, 0, 1); // red
		sum += tex2D(_MainTex, i.uv + _amplitudeGreen/100 * axisG[_axisG]) * float4(0, 1, 0, 1); // green
		sum += tex2D(_MainTex, i.uv + _amplitudeBlue/100 * axisB[_axisB]) * float4(0, 0, 1, 1); // blue

    	return fixed4(sum/2);
	}

	ENDCG 
	
	Subshader 
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
	Fallback off	
}
