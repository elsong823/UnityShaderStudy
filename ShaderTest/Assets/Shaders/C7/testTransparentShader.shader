Shader "MyShader/c8/testTransparentShader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_TransTex("Trans", 2D) = "white"{}
		_Cutoff("Cutoff", Range(0,1)) = 1.0
	}

	SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
			"Queue" = "Geometry+5"
			"IgnoreProjector" = "True"
			"Transparent" = "cutout"
		}
		ZWrite off
		Blend srcAlpha oneMinusSrcAlpha
		Pass
		{
			Cull Front
			CGPROGRAM

			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _TransTex;
			float4 _TransTex_ST;
			float _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			v2f Vert(in a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.texcoord.xy * _TransTex_ST.xy + _TransTex_ST.zw;
				o.worldPos = mul(_Object2World, i.vertex).xyz;
				o.worldNormal = mul(i.normal, (float3x3)_World2Object);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed4 transColor = tex2D(_TransTex, i.uv);
				clip(transColor.a - _Cutoff);

				fixed3 worldNormal = normalize( i.worldNormal );
				fixed3 worldLight = normalize( UnityWorldSpaceLightDir(i.worldPos) );

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * transColor.rgb;

				fixed3 diffuse = _LightColor0 * transColor.rgb * saturate(dot(worldLight, worldNormal));

				return fixed4(ambient + diffuse, transColor.a);
			}

			ENDCG
		}

		Pass
		{
			Cull Back
			CGPROGRAM

			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _TransTex;
			float4 _TransTex_ST;
			float _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			v2f Vert(in a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.texcoord.xy * _TransTex_ST.xy + _TransTex_ST.zw;
				o.worldPos = mul(_Object2World, i.vertex).xyz;
				o.worldNormal = mul(i.normal, (float3x3)_World2Object);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed4 transColor = tex2D(_TransTex, i.uv);
				clip(transColor.a - _Cutoff);

				fixed3 worldNormal = normalize( i.worldNormal );
				fixed3 worldLight = normalize( UnityWorldSpaceLightDir(i.worldPos) );

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * transColor.rgb;

				fixed3 diffuse = _LightColor0 * transColor.rgb * saturate(dot(worldLight, worldNormal));

				return fixed4(ambient + diffuse, transColor.a);
			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}