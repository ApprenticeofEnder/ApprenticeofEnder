#!/usr/bin/env python3
import json
import math
import sys
from dataclasses import dataclass
from datetime import datetime
from enum import IntEnum
from typing import Any

number_names = ["", "K", "M", "B", "T"]


def human_readable_number(num: float | int) -> str:
    num = float(num)

    last_number_name_index = len(number_names) - 1

    num_sections = 0
    if num != 0:
        num_sections = math.floor(math.log10(abs(num)) / 3)

    name_index = max(0, min(last_number_name_index, num_sections))

    rendered_num = num / 10 ** (3 * name_index)

    return f"{rendered_num:,.2f}{number_names[name_index]}"


class AnsiColor(IntEnum):
    BLACK = 0
    RED = 1
    GREEN = 2
    YELLOW = 3
    BLUE = 4
    MAGENTA = 5
    CYAN = 6
    WHITE = 7


class Ansi:
    SEQUENCE_START = "\x1b["
    FOREGROUND_STANDARD = "3"
    BACKGROUND_STANDARD = "4"
    FOREGROUND_BRIGHT = "9"
    BACKGROUND_BRIGHT = "10"

    @classmethod
    def get_color(
        cls,
        color: AnsiColor,
        is_background: bool = False,
        is_bright: bool = False,
    ):
        selector = 3
        if is_background:
            selector += 1

        if is_bright:
            selector += 6
        return f"{cls.SEQUENCE_START}{selector}{color}m"

    @classmethod
    def render(
        cls,
        text: str,
        foreground_color: AnsiColor | None = None,
        background_color: AnsiColor | None = None,
        foreground_bright: bool = False,
        background_bright: bool = False,
    ):
        if foreground_color is None and background_color is None:
            return text

        prefix = ""
        reset_code = f"{cls.SEQUENCE_START}0m"

        if foreground_color is not None:
            prefix += cls.get_color(
                foreground_color, is_bright=foreground_bright
            )
        if background_color is not None:
            prefix += cls.get_color(
                background_color,
                is_background=True,
                is_bright=background_bright,
            )

        return f"{prefix}{text}{reset_code}"


@dataclass
class StatuslineInput:
    model: "ModelData"
    cost: "CostData"
    context_window: "ContextWindowData"

    def render(self) -> str:
        rendered_fieldsets = []
        for fieldset in [self.model, self.cost, self.context_window]:
            rendered_fieldsets.append(fieldset.render())

        return "\n".join(rendered_fieldsets)


@dataclass
class FieldSet:
    def render(self, **fields) -> str:
        return "\n".join(
            [f"{key.upper() + ':':10}{value}" for key, value in fields.items()]
        )


@dataclass
class ModelData(FieldSet):
    id: str
    display_name: str

    @property
    def model_colour(self) -> AnsiColor:
        match self.display_name:
            case "Opus":
                return AnsiColor.YELLOW
            case "Fable":
                return AnsiColor.RED
            case "Haiku":
                return AnsiColor.GREEN
            case _:
                return AnsiColor.WHITE

    def render(self) -> str:
        return super().render(
            model=Ansi.render(
                self.display_name, foreground_color=self.model_colour
            )
        )


@dataclass
class CostData(FieldSet):
    total_cost_usd: float
    total_duration_ms: int
    total_api_duration_ms: int
    total_lines_added: int
    total_lines_removed: int

    @property
    def human_duration(self):
        timestamp = datetime.fromtimestamp(self.total_duration_ms / 1000.0)
        return timestamp.strftime("%H:%M:%S")

    def render(self) -> str:
        return super().render(
            cost=Ansi.render(
                f"${self.total_cost_usd:.2f} USD",
                foreground_color=AnsiColor.GREEN,
            ),
            duration=self.human_duration,
        )


@dataclass
class ContextWindowData(FieldSet):
    total_input_tokens: int
    total_output_tokens: int
    context_window_size: int
    used_percentage: int | None = None
    remaining_percentage: int | None = None

    @property
    def rendered_context_size(self) -> str:
        return human_readable_number(self.context_window_size)

    def render(self) -> str:
        color = AnsiColor.GREEN
        if self.used_percentage > 50:
            color = AnsiColor.YELLOW
        if self.used_percentage > 70:
            color = AnsiColor.RED

        rendered_context = Ansi.render(
            f"{self.used_percentage}/100% [{self.rendered_context_size}]",
            foreground_color=color,
        )
        return super().render(context=rendered_context)


def load_statusline_input(input_data: dict[Any, Any]) -> StatuslineInput:
    model_data = ModelData(**input_data.get("model", {}))
    cost_data = CostData(**input_data.get("cost", {}))
    context_window_data = ContextWindowData(
        **input_data.get("context_window", {})
    )

    return StatuslineInput(
        model=model_data, cost=cost_data, context_window=context_window_data
    )


def main():
    data: StatuslineInput = json.load(
        sys.stdin, object_hook=load_statusline_input
    )
    print(data.render())


if __name__ == "__main__":
    main()
