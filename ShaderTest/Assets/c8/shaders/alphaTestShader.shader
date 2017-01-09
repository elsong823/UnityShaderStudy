Shader "MyShader/c8/alphaTest"
{
	Properties
	{
		_TransTex("TransTex", 2D) = "white"{}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.0
	}

	SubShader
	{
		Tags{
				"Queue" = "AlphaTest"
				"IgnoreProjector" = "true"
				"RenderType" = "TransparentCutout"
			}
		Pass
		{	
			Tags{ 
					"LightMode" = "ForwardBase" 
				}
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _TransTex;
			float4 _TransTex_ST;
			fixed4 _Color;
			fixed _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f Vert(in a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _TransTex);
				o.worldPos = mul(_Object2World, v.vertex).xyz;
				o.worldNormal = mul(v.normal, (float3x3)_World2Object);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed4 texColor = tex2D(_TransTex, i.uv);

				clip(texColor.a - _Cutoff);

				fixed3 worldNormal = normalize( i.worldNormal );
				fixed3 worldLight = normalize( UnityWorldSpaceLightDir(i.worldPos) );
				fixed3 worldView = normalize( UnityWorldSpaceViewDir(i.worldPos) );
				fixed3 worldHalf = normalize( worldLight + worldView );

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor.rgb;

				fixed3 diffuse = texColor.rgb * _LightColor0.rgb * saturate( dot(worldLight, worldNormal) );

				return fixed4(ambient + diffuse, 1.0);
			}


			ENDCG
		}
	}

	Fallback "Transparent/Cutout/VertexLit"

}