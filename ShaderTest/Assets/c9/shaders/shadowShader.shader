Shader "MyShader/c9/shadowShader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess("Shininess", Range(8, 256)) = 128
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}
			// Pass to render object as a shadow caster
		Pass {
			// Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f { 
				V2F_SHADOW_CASTER;
			};

			v2f vert( appdata_base v )
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag( v2f i ) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)	
			}
			ENDCG

		}
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma multi_compile_fwdbase
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			float _Shininess;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f Vert(in appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldPos = mul(_Object2World, v.vertex).xyz;

				o.worldNormal = mul(v.normal, (float3x3)_World2Object);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldHalf = normalize(worldLight + worldView);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldLight, worldNormal));

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldHalf, worldNormal)), _Shininess);

				fixed atten = 1.0;

				fixed shadow = SHADOW_ATTENUATION(i);

				return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			Blend SrcAlpha One

			CGPROGRAM

			#pragma multi_compile_fwdadd
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			float _Shininess;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f Vert(in appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldPos = mul(_Object2World, v.vertex).xyz;

				o.worldNormal = mul(v.normal, (float3x3)_World2Object);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLight = normalize(_WorldSpaceLightPos0);
				#else
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);	
				#endif

				fixed3 worldHalf = normalize(worldLight + worldView);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldLight, worldNormal));

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldHalf, worldNormal)), _Shininess);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;		
				#else
					#if defined(POINT)
						float3 lightCoord = mul(_LightMatrix0, float4(i.worldPos, 1.0)).xyz;
						fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
					#elif defined(SPOT)
						float4 lightCoord = mul(_LightMatrix0, float4(i.worldPos, 1.0));
						fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
					#else 
						fixed atten = 1.0;		
					#endif
				#endif

				fixed shadow = SHADOW_ATTENUATION(i);
				return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
			}


			ENDCG
		}
	}

	// Fallback "Specular"
}