from google.genai import types
from google.adk.agents import Agent
from google.adk.apps import App
from google.adk.agents.callback_context import CallbackContext

from google.adk.tools.google_search_tool import GoogleSearchTool


google_search = GoogleSearchTool(bypass_multi_tools_limit=True)

from cymbal_navigation_agent.tools import (
    search_google_maps,
    get_route_directions,
)

async def initialize_state(callback_context: CallbackContext) -> None:
    """Initialize default session state variables to prevent KeyError issues during runtime."""
    state = callback_context.state
    if "user_location" not in state:
        state["user_location"] = "San Francisco, CA"
    if "preferred_mode" not in state:
        state["preferred_mode"] = "driving"

SYSTEM_INSTRUCTION = """You are Cymbal Navigation & Planner Agent, an intelligent location-aware travel and event planning assistant built for Cymbal Group.

Your core capabilities:
1. Search Google using the built-in Google Search grounding tool (`google_search`) for up-to-date web information, events, reviews, and event scheduling.
2. Search Google Maps (`search_google_maps`) via API for exact physical addresses, ratings, coordinates, and place information.
3. Calculate Navigation Routes (`get_route_directions`) via API for driving, transit, walking, or bicycling between locations.

Execution Workflow Rules:
- If a user asks for live web info, local news, or web search recommendations, ground your answer using `google_search`.
- If a user asks for place details, physical addresses, or ratings, invoke `search_google_maps`.
- If a user requests travel directions or route options, invoke `get_route_directions`.
- Synthesize all tool output into a clean, well-formatted response with clear bullet points and actionable navigation tips.
"""

root_agent = Agent(
    name="cymbal_navigation_planner",
    model="gemini-2.5-flash",
    instruction=SYSTEM_INSTRUCTION,
    tools=[google_search, search_google_maps, get_route_directions],
    before_agent_callback=initialize_state,
)

# Crucial for ADK / Agent Runtime: App name must match directory name
app = App(root_agent=root_agent, name="cymbal_navigation_agent")
