package configurator

import (
	"fmt"
	"path/filepath"
	"runtime"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/huh"
)

type TeaModel struct {
	config    *HoneycombConfig
	form      *huh.Form
	completed bool
}

func NewTeaModel() TeaModel {
	m := TeaModel{}
	m.completed = false

	m.config = &HoneycombConfig{}
	m.form = huh.NewForm(
		huh.NewGroup(
			huh.NewInput().
				Key("module-name").
				Title("Go Module name").
				Description("example: github.com/repo/my-module"),
		),
		huh.NewGroup(
			huh.NewInput().
				Key("go-version").
				Title("Go version").
				Placeholder(runtime.Version()),
		),
	)

	return m
}

func (m TeaModel) GetHoneyCombConfig() (*HoneycombConfig, error) {
	if !m.completed {
		return nil, fmt.Errorf("configurator not completed")
	}

	return m.config, nil
}

func (m TeaModel) Init() tea.Cmd {
	return m.form.Init()
}

func (m TeaModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "esc", "ctrl+c", "q":
			return m, tea.Quit
		}
	}

	var cmds []tea.Cmd

	// Process the form
	form, cmd := m.form.Update(msg)
	if f, ok := form.(*huh.Form); ok {
		m.form = f
		cmds = append(cmds, cmd)
	}

	if m.form.State == huh.StateCompleted {
		m.completed = true
		cmds = append(cmds, tea.Quit)
	}

	return m, tea.Batch(cmds...)
}

func (m TeaModel) View() string {
	switch m.form.State {
	case huh.StateCompleted:
		m.config.ModuleName = m.form.GetString("module-name")
		m.config.ProjectName = getProjectName(m.config.ModuleName)
		m.config.GoVersion = runtime.Version()

		m.config.ProjectPath = filepath.Join(".", m.config.ProjectName)
		m.config.CfgEnvPrefix = strings.ToUpper(strings.ReplaceAll(m.config.ProjectName, "-", "_"))

		return "All done!\n"
	default:
		return m.form.View()
	}
}

func getProjectName(moduleName string) string {
	splitStr := strings.Split(moduleName, "/")
	return splitStr[len(splitStr)-1]
}
